# 24 - Cloud Functions für Analyse

## Übersicht

Firebase Cloud Functions zur automatischen Aggregation und Analyse der DeepScan-Daten.

---

## Projektstruktur

```
functions/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts              # Exports
│   ├── analytics/
│   │   ├── aggregation.ts    # Statistik-Berechnung
│   │   ├── gaps.ts           # Lücken-Erkennung
│   │   └── insights.ts       # Insight-Generierung
│   ├── triggers/
│   │   ├── onLocationChange.ts
│   │   └── scheduled.ts
│   └── utils/
│       ├── geo.ts
│       └── helpers.ts
```

---

## 1. Package.json

```json
{
  "name": "msh-map-functions",
  "version": "1.0.0",
  "main": "lib/index.js",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "deploy": "firebase deploy --only functions"
  },
  "engines": {
    "node": "18"
  },
  "dependencies": {
    "firebase-admin": "^11.10.1",
    "firebase-functions": "^4.4.1"
  },
  "devDependencies": {
    "typescript": "^5.2.2"
  }
}
```

---

## 2. Index.ts (Exports)

```typescript
// functions/src/index.ts

import * as admin from 'firebase-admin';

admin.initializeApp();

// Scheduled Functions
export { updateDailyStats } from './triggers/scheduled';
export { updateWeeklyReport } from './triggers/scheduled';

// Trigger Functions
export { onLocationCreated, onLocationUpdated } from './triggers/onLocationChange';

// HTTP Functions (für manuelle Trigger)
export { recalculateAll } from './analytics/aggregation';
```

---

## 3. Aggregation

```typescript
// functions/src/analytics/aggregation.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { haversineDistance } from '../utils/geo';

const db = admin.firestore();

interface CategoryCount {
  [category: string]: number;
}

interface CityStats {
  cityName: string;
  locationCount: number;
  categoryDistribution: CategoryCount;
  coverageScore: number;
  familyScore: number;
  avgRating: number | null;
  population: number;
}

// Bekannte Städte mit Einwohnerzahlen
const CITIES: Record<string, { lat: number; lng: number; pop: number }> = {
  'Sangerhausen': { lat: 51.4667, lng: 11.3000, pop: 26000 },
  'Lutherstadt Eisleben': { lat: 51.5275, lng: 11.5481, pop: 24000 },
  'Hettstedt': { lat: 51.6500, lng: 11.5000, pop: 15000 },
  'Mansfeld': { lat: 51.5972, lng: 11.4528, pop: 9000 },
  'Nordhausen': { lat: 51.5000, lng: 10.7833, pop: 42000 },
  'Allstedt': { lat: 51.4000, lng: 11.3833, pop: 8000 },
};

// Mindest-Infrastruktur pro 10.000 Einwohner
const MIN_PER_10K: Record<string, number> = {
  'playground': 3,
  'pool': 0.5,
  'museum': 0.5,
  'restaurant': 5,
};

/**
 * Berechnet alle Statistiken neu
 */
export const recalculateAll = functions.https.onRequest(async (req, res) => {
  try {
    await calculateRegionOverview();
    await calculateCityStats();
    await detectGaps();
    await generateInsights();
    
    res.json({ success: true, message: 'Recalculation complete' });
  } catch (error) {
    console.error('Recalculation failed:', error);
    res.status(500).json({ success: false, error: String(error) });
  }
});

/**
 * Berechnet Gesamt-Übersicht
 */
export async function calculateRegionOverview(): Promise<void> {
  const locationsSnap = await db.collection('locations').get();
  
  const categoryTotals: CategoryCount = {};
  const cities = new Set<string>();
  
  locationsSnap.docs.forEach(doc => {
    const data = doc.data();
    const category = data.category || 'other';
    categoryTotals[category] = (categoryTotals[category] || 0) + 1;
    if (data.city) cities.add(data.city);
  });
  
  await db.collection('analytics').doc('region_overview').set({
    totalLocations: locationsSnap.size,
    totalCities: cities.size,
    categoryTotals,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  
  console.log(`Region overview updated: ${locationsSnap.size} locations`);
}

/**
 * Berechnet Statistiken pro Stadt
 */
export async function calculateCityStats(): Promise<void> {
  const locationsSnap = await db.collection('locations').get();
  
  // Gruppiere nach Stadt
  const cityData: Record<string, any[]> = {};
  
  locationsSnap.docs.forEach(doc => {
    const data = doc.data();
    const city = findNearestCity(data.latitude, data.longitude, data.city);
    if (!cityData[city]) cityData[city] = [];
    cityData[city].push(data);
  });
  
  // Berechne Stats pro Stadt
  const batch = db.batch();
  
  for (const [cityName, locations] of Object.entries(cityData)) {
    const categoryDist: CategoryCount = {};
    let ratingSum = 0;
    let ratingCount = 0;
    
    locations.forEach(loc => {
      const cat = loc.category || 'other';
      categoryDist[cat] = (categoryDist[cat] || 0) + 1;
      if (loc.rating) {
        ratingSum += loc.rating;
        ratingCount++;
      }
    });
    
    const cityInfo = CITIES[cityName];
    const population = cityInfo?.pop || 10000;
    
    const stats: CityStats = {
      cityName,
      locationCount: locations.length,
      categoryDistribution: categoryDist,
      coverageScore: calculateCoverageScore(categoryDist, population),
      familyScore: calculateFamilyScore(categoryDist, population),
      avgRating: ratingCount > 0 ? ratingSum / ratingCount : null,
      population,
    };
    
    const docRef = db
      .collection('analytics')
      .doc('city_stats')
      .collection('cities')
      .doc(cityName.toLowerCase().replace(/\s+/g, '-'));
    
    batch.set(docRef, stats);
  }
  
  await batch.commit();
  console.log(`City stats updated for ${Object.keys(cityData).length} cities`);
}

/**
 * Findet nächste bekannte Stadt
 */
function findNearestCity(lat?: number, lng?: number, cityHint?: string): string {
  // Zuerst Hint prüfen
  if (cityHint) {
    for (const city of Object.keys(CITIES)) {
      if (city.toLowerCase().includes(cityHint.toLowerCase()) ||
          cityHint.toLowerCase().includes(city.toLowerCase())) {
        return city;
      }
    }
  }
  
  // Dann nach Distanz
  if (lat && lng) {
    let nearest = 'Unbekannt';
    let minDist = Infinity;
    
    for (const [city, info] of Object.entries(CITIES)) {
      const dist = haversineDistance(lat, lng, info.lat, info.lng);
      if (dist < minDist) {
        minDist = dist;
        nearest = city;
      }
    }
    
    return nearest;
  }
  
  return 'Unbekannt';
}

/**
 * Berechnet Coverage Score (0-1)
 */
function calculateCoverageScore(categories: CategoryCount, population: number): number {
  const pop10k = population / 10000;
  let scores: number[] = [];
  
  for (const [cat, minPer10k] of Object.entries(MIN_PER_10K)) {
    const actual = categories[cat] || 0;
    const expected = minPer10k * pop10k;
    if (expected > 0) {
      scores.push(Math.min(1, actual / expected));
    }
  }
  
  return scores.length > 0 
    ? scores.reduce((a, b) => a + b, 0) / scores.length 
    : 0.5;
}

/**
 * Berechnet Family Score (0-1)
 */
function calculateFamilyScore(categories: CategoryCount, population: number): number {
  const familyCategories = ['playground', 'pool', 'zoo', 'museum', 'nature'];
  const pop10k = population / 10000;
  
  let total = 0;
  familyCategories.forEach(cat => {
    total += categories[cat] || 0;
  });
  
  // Ideal: 10 Familien-Orte pro 10k Einwohner
  const expected = 10 * pop10k;
  return Math.min(1, total / expected);
}
```

---

## 4. Gap Detection

```typescript
// functions/src/analytics/gaps.ts

import * as admin from 'firebase-admin';
import { haversineDistance } from '../utils/geo';

const db = admin.firestore();

interface Gap {
  id: string;
  gapType: string;
  latitude: number;
  longitude: number;
  severity: 'critical' | 'moderate' | 'low';
  description: string;
  affectedArea: string;
  affectedPopulation?: number;
  recommendation?: string;
}

const CITIES = {
  'Sangerhausen': { lat: 51.4667, lng: 11.3000, pop: 26000 },
  'Lutherstadt Eisleben': { lat: 51.5275, lng: 11.5481, pop: 24000 },
  'Hettstedt': { lat: 51.6500, lng: 11.5000, pop: 15000 },
  'Mansfeld': { lat: 51.5972, lng: 11.4528, pop: 9000 },
  'Allstedt': { lat: 51.4000, lng: 11.3833, pop: 8000 },
};

/**
 * Erkennt Infrastruktur-Lücken
 */
export async function detectGaps(): Promise<void> {
  const gaps: Gap[] = [];
  
  // Lade alle Locations
  const locationsSnap = await db.collection('locations').get();
  const locations = locationsSnap.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
  
  // Spielplatz-Wüsten
  gaps.push(...detectPlaygroundDeserts(locations));
  
  // Schwimmbad-Gaps
  gaps.push(...detectCategoryGaps(locations, 'pool', 15, 'Schwimmbad'));
  
  // Museum-Gaps
  gaps.push(...detectCategoryGaps(locations, 'museum', 20, 'Museum'));
  
  // Gastronomie-Gaps
  gaps.push(...detectCategoryGaps(locations, 'restaurant', 5, 'Restaurant'));
  
  // Speichern
  const batch = db.batch();
  
  // Alte Gaps löschen
  const oldGaps = await db.collection('analytics').doc('gaps').collection('items').get();
  oldGaps.docs.forEach(doc => batch.delete(doc.ref));
  
  // Neue Gaps speichern
  gaps.forEach(gap => {
    const docRef = db.collection('analytics').doc('gaps').collection('items').doc(gap.id);
    batch.set(docRef, gap);
  });
  
  await batch.commit();
  console.log(`Detected ${gaps.length} infrastructure gaps`);
}

/**
 * Findet Gebiete ohne Spielplatz
 */
function detectPlaygroundDeserts(locations: any[]): Gap[] {
  const gaps: Gap[] = [];
  const playgrounds = locations.filter(l => l.category === 'playground');
  const MAX_DISTANCE = 3; // km
  
  for (const [cityName, cityInfo] of Object.entries(CITIES)) {
    let minDist = Infinity;
    
    playgrounds.forEach(pg => {
      if (pg.latitude && pg.longitude) {
        const dist = haversineDistance(
          cityInfo.lat, cityInfo.lng,
          pg.latitude, pg.longitude
        );
        minDist = Math.min(minDist, dist);
      }
    });
    
    if (minDist > MAX_DISTANCE) {
      const severity = minDist > 5 ? 'critical' : 'moderate';
      gaps.push({
        id: `playground-desert-${cityName.toLowerCase().replace(/\s+/g, '-')}`,
        gapType: 'playground_desert',
        latitude: cityInfo.lat,
        longitude: cityInfo.lng,
        severity,
        description: `${cityName}: Nächster Spielplatz ${minDist.toFixed(1)} km entfernt`,
        affectedArea: cityName,
        affectedPopulation: cityInfo.pop,
        recommendation: `Spielplatz im Zentrum von ${cityName} einrichten`,
      });
    }
  }
  
  return gaps;
}

/**
 * Generische Gap-Erkennung für Kategorie
 */
function detectCategoryGaps(
  locations: any[], 
  category: string, 
  maxDistance: number,
  categoryLabel: string
): Gap[] {
  const gaps: Gap[] = [];
  const categoryLocations = locations.filter(l => l.category === category);
  
  for (const [cityName, cityInfo] of Object.entries(CITIES)) {
    let minDist = Infinity;
    
    categoryLocations.forEach(loc => {
      if (loc.latitude && loc.longitude) {
        const dist = haversineDistance(
          cityInfo.lat, cityInfo.lng,
          loc.latitude, loc.longitude
        );
        minDist = Math.min(minDist, dist);
      }
    });
    
    if (minDist > maxDistance) {
      gaps.push({
        id: `no-${category}-${cityName.toLowerCase().replace(/\s+/g, '-')}`,
        gapType: `no_${category}`,
        latitude: cityInfo.lat,
        longitude: cityInfo.lng,
        severity: 'moderate',
        description: `${cityName}: Kein ${categoryLabel} im Umkreis von ${maxDistance}km`,
        affectedArea: cityName,
        affectedPopulation: cityInfo.pop,
      });
    }
  }
  
  return gaps;
}
```

---

## 5. Insights

```typescript
// functions/src/analytics/insights.ts

import * as admin from 'firebase-admin';

const db = admin.firestore();

interface Insight {
  id: string;
  type: 'trend' | 'gap' | 'achievement' | 'recommendation';
  title: string;
  description: string;
  metric?: string;
  value?: number;
  createdAt: admin.firestore.FieldValue;
}

/**
 * Generiert automatische Insights
 */
export async function generateInsights(): Promise<void> {
  const insights: Insight[] = [];
  
  // Lade Daten
  const overviewDoc = await db.collection('analytics').doc('region_overview').get();
  const overview = overviewDoc.data();
  
  if (!overview) return;
  
  const totalLocations = overview.totalLocations || 0;
  const categoryTotals = overview.categoryTotals || {};
  
  // Insight: Gesamtzahl
  insights.push({
    id: 'total-locations',
    type: 'achievement',
    title: `${totalLocations} Orte erfasst`,
    description: 'Die MSH Map wächst weiter und bietet immer mehr Informationen für die Region.',
    metric: 'locations',
    value: totalLocations,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  // Insight: Top-Kategorie
  const topCategory = Object.entries(categoryTotals)
    .sort((a, b) => (b[1] as number) - (a[1] as number))[0];
  
  if (topCategory) {
    insights.push({
      id: 'top-category',
      type: 'trend',
      title: `${topCategory[0]} ist die stärkste Kategorie`,
      description: `Mit ${topCategory[1]} Einträgen ist "${topCategory[0]}" am besten abgedeckt.`,
      metric: topCategory[0],
      value: topCategory[1] as number,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  
  // Insight: Spielplätze pro Einwohner
  const playgroundCount = categoryTotals['playground'] || 0;
  const totalPop = 120000; // Geschätzte Gesamtbevölkerung
  const playgroundPer10k = (playgroundCount / (totalPop / 10000));
  
  if (playgroundPer10k < 2) {
    insights.push({
      id: 'playground-shortage',
      type: 'gap',
      title: 'Spielplatz-Abdeckung verbesserungswürdig',
      description: `Nur ${playgroundPer10k.toFixed(1)} Spielplätze pro 10.000 Einwohner (Empfehlung: ≥3)`,
      metric: 'playgrounds_per_10k',
      value: playgroundPer10k,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    insights.push({
      id: 'playground-good',
      type: 'achievement',
      title: 'Gute Spielplatz-Versorgung',
      description: `${playgroundPer10k.toFixed(1)} Spielplätze pro 10.000 Einwohner`,
      metric: 'playgrounds_per_10k',
      value: playgroundPer10k,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  
  // Insight: Kategorien mit wenig Einträgen
  for (const [cat, count] of Object.entries(categoryTotals)) {
    if ((count as number) < 5 && cat !== 'other') {
      insights.push({
        id: `low-${cat}`,
        type: 'recommendation',
        title: `Mehr ${cat}-Daten sammeln`,
        description: `Die Kategorie "${cat}" hat nur ${count} Einträge. Hier fehlen noch Informationen.`,
        metric: cat,
        value: count as number,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Speichern
  const batch = db.batch();
  
  insights.forEach(insight => {
    const docRef = db.collection('analytics').doc('insights').collection('items').doc(insight.id);
    batch.set(docRef, insight);
  });
  
  await batch.commit();
  console.log(`Generated ${insights.length} insights`);
}
```

---

## 6. Scheduled Triggers

```typescript
// functions/src/triggers/scheduled.ts

import * as functions from 'firebase-functions';
import { calculateRegionOverview, calculateCityStats } from '../analytics/aggregation';
import { detectGaps } from '../analytics/gaps';
import { generateInsights } from '../analytics/insights';

/**
 * Tägliche Aktualisierung um 3 Uhr nachts
 */
export const updateDailyStats = functions.pubsub
  .schedule('0 3 * * *')
  .timeZone('Europe/Berlin')
  .onRun(async () => {
    console.log('Starting daily stats update...');
    
    await calculateRegionOverview();
    await calculateCityStats();
    await detectGaps();
    await generateInsights();
    
    console.log('Daily stats update complete');
  });

/**
 * Wöchentlicher Report (Sonntag 6 Uhr)
 */
export const updateWeeklyReport = functions.pubsub
  .schedule('0 6 * * 0')
  .timeZone('Europe/Berlin')
  .onRun(async () => {
    console.log('Generating weekly report...');
    
    // TODO: Erweiterten Wochen-Report generieren
    // - Vergleich zur Vorwoche
    // - Top-Veränderungen
    // - Neue Locations
    
    console.log('Weekly report complete');
  });
```

---

## 7. Location Change Triggers

```typescript
// functions/src/triggers/onLocationChange.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Wenn eine neue Location erstellt wird
 */
export const onLocationCreated = functions.firestore
  .document('locations/{locationId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // Kategorie-Counter erhöhen
    const category = data.category || 'other';
    await db.collection('analytics').doc('region_overview').update({
      [`categoryTotals.${category}`]: admin.firestore.FieldValue.increment(1),
      totalLocations: admin.firestore.FieldValue.increment(1),
    });
    
    console.log(`Location created: ${data.name} (${category})`);
  });

/**
 * Wenn eine Location aktualisiert wird
 */
export const onLocationUpdated = functions.firestore
  .document('locations/{locationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Kategorie geändert?
    if (before.category !== after.category) {
      await db.collection('analytics').doc('region_overview').update({
        [`categoryTotals.${before.category}`]: admin.firestore.FieldValue.increment(-1),
        [`categoryTotals.${after.category}`]: admin.firestore.FieldValue.increment(1),
      });
    }
    
    // View-Count erhöht? (Popularity Update)
    if ((after.viewCount || 0) > (before.viewCount || 0)) {
      // Könnte Popularity-Score neu berechnen
    }
  });
```

---

## 8. Geo Utils

```typescript
// functions/src/utils/geo.ts

/**
 * Berechnet Distanz zwischen zwei Punkten in km
 */
export function haversineDistance(
  lat1: number, lon1: number,
  lat2: number, lon2: number
): number {
  const R = 6371; // Erdradius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(deg: number): number {
  return deg * (Math.PI / 180);
}

/**
 * Prüft ob Punkt in Bounding Box liegt
 */
export function isInBounds(
  lat: number, lng: number,
  bounds: { north: number; south: number; east: number; west: number }
): boolean {
  return lat >= bounds.south && lat <= bounds.north &&
         lng >= bounds.west && lng <= bounds.east;
}
```

---

## Deployment

```bash
# Im functions/ Verzeichnis:
npm install
npm run build
firebase deploy --only functions
```

## Manuelle Neuberechnung

Nach dem Deployment kann die Neuberechnung manuell getriggert werden:

```bash
curl https://[REGION]-[PROJECT].cloudfunctions.net/recalculateAll
```
