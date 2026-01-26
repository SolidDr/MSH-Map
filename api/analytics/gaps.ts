/**
 * Infrastruktur-Lücken Erkennung
 */

import * as admin from "firebase-admin";
import {getFirestore} from "../utils/firebase";
import {haversineDistance} from "../utils/geo";

interface Gap {
  id: string;
  gapType: string;
  latitude: number;
  longitude: number;
  severity: "critical" | "moderate" | "low";
  description: string;
  affectedArea: string;
  affectedPopulation?: number;
  recommendation?: string;
  createdAt: admin.firestore.FieldValue;
}

const CITIES = {
  "Sangerhausen": {lat: 51.4667, lng: 11.3, pop: 26000},
  "Lutherstadt Eisleben": {lat: 51.5275, lng: 11.5481, pop: 24000},
  "Hettstedt": {lat: 51.65, lng: 11.5, pop: 15000},
  "Mansfeld": {lat: 51.5972, lng: 11.4528, pop: 9000},
  "Allstedt": {lat: 51.4, lng: 11.3833, pop: 8000},
};

/**
 * Hauptfunktion: Erkennt alle Infrastruktur-Lücken
 */
export async function detectGaps(): Promise<void> {
  console.log("Detecting infrastructure gaps...");

  const db = getFirestore();
  const gaps: Gap[] = [];

  // Lade alle Locations
  const locationsSnap = await db.collection("locations").get();
  const locations = locationsSnap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  // Verschiedene Gap-Typen
  gaps.push(...detectPlaygroundDeserts(locations));
  gaps.push(...detectCategoryGaps(locations, "pool", 15, "Schwimmbad"));
  gaps.push(...detectCategoryGaps(locations, "museum", 20, "Museum"));
  gaps.push(...detectCategoryGaps(locations, "restaurant", 5, "Restaurant"));

  // Speichern
  const batch = db.batch();

  // Alte Gaps löschen
  const oldGaps = await db
    .collection("analytics")
    .doc("gaps")
    .collection("items")
    .get();
  oldGaps.docs.forEach((doc) => batch.delete(doc.ref));

  // Neue Gaps speichern
  gaps.forEach((gap) => {
    const docRef = db
      .collection("analytics")
      .doc("gaps")
      .collection("items")
      .doc(gap.id);
    batch.set(docRef, gap);
  });

  await batch.commit();
  console.log(`Detected ${gaps.length} infrastructure gaps`);
}

/**
 * Findet Gebiete ohne Spielplatz (Playground Deserts)
 */
function detectPlaygroundDeserts(locations: any[]): Gap[] {
  const gaps: Gap[] = [];
  const playgrounds = locations.filter(
    (l) => l.category === "playground"
  );
  const MAX_DISTANCE = 3; // km

  for (const [cityName, cityInfo] of Object.entries(CITIES)) {
    let minDist = Infinity;

    playgrounds.forEach((pg) => {
      if (pg.coordinates?.latitude && pg.coordinates?.longitude) {
        const dist = haversineDistance(
          cityInfo.lat,
          cityInfo.lng,
          pg.coordinates.latitude,
          pg.coordinates.longitude
        );
        minDist = Math.min(minDist, dist);
      }
    });

    if (minDist > MAX_DISTANCE) {
      const severity = minDist > 5 ? "critical" : "moderate";
      gaps.push({
        id: `playground-desert-${cityName
          .toLowerCase()
          .replace(/\s+/g, "-")}`,
        gapType: "playground_desert",
        latitude: cityInfo.lat,
        longitude: cityInfo.lng,
        severity,
        description: `${cityName}: Nächster Spielplatz ${minDist.toFixed(
          1
        )} km entfernt`,
        affectedArea: cityName,
        affectedPopulation: cityInfo.pop,
        recommendation: `Spielplatz im Zentrum von ${cityName} einrichten`,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  return gaps;
}

/**
 * Generische Gap-Erkennung für eine Kategorie
 */
function detectCategoryGaps(
  locations: any[],
  category: string,
  maxDistance: number,
  categoryLabel: string
): Gap[] {
  const gaps: Gap[] = [];
  const categoryLocations = locations.filter(
    (l) => l.category === category
  );

  for (const [cityName, cityInfo] of Object.entries(CITIES)) {
    let minDist = Infinity;

    categoryLocations.forEach((loc) => {
      if (loc.coordinates?.latitude && loc.coordinates?.longitude) {
        const dist = haversineDistance(
          cityInfo.lat,
          cityInfo.lng,
          loc.coordinates.latitude,
          loc.coordinates.longitude
        );
        minDist = Math.min(minDist, dist);
      }
    });

    if (minDist > maxDistance) {
      gaps.push({
        id: `no-${category}-${cityName
          .toLowerCase()
          .replace(/\s+/g, "-")}`,
        gapType: `no_${category}`,
        latitude: cityInfo.lat,
        longitude: cityInfo.lng,
        severity: "moderate",
        description: `${cityName}: Kein ${categoryLabel} im Umkreis von ${maxDistance}km`,
        affectedArea: cityName,
        affectedPopulation: cityInfo.pop,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  return gaps;
}
