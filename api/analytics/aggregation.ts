/**
 * Daten-Aggregation und Statistik-Berechnung
 */

import * as admin from "firebase-admin";
import {getFirestore} from "../utils/firebase";
import {haversineDistance} from "../utils/geo";

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
  lastUpdated: admin.firestore.FieldValue;
}

// Bekannte Städte mit Einwohnerzahlen
const CITIES: Record<string, {lat: number; lng: number; pop: number}> = {
  "Sangerhausen": {lat: 51.4667, lng: 11.3, pop: 26000},
  "Lutherstadt Eisleben": {lat: 51.5275, lng: 11.5481, pop: 24000},
  "Hettstedt": {lat: 51.65, lng: 11.5, pop: 15000},
  "Mansfeld": {lat: 51.5972, lng: 11.4528, pop: 9000},
  "Allstedt": {lat: 51.4, lng: 11.3833, pop: 8000},
  "Nordhausen": {lat: 51.5, lng: 10.7833, pop: 42000},
};

// Mindest-Infrastruktur pro 10.000 Einwohner
const MIN_PER_10K: Record<string, number> = {
  "playground": 3,
  "pool": 0.5,
  "museum": 0.5,
  "restaurant": 5,
};

/**
 * Berechnet Gesamt-Übersicht der Region
 */
export async function calculateRegionOverview(): Promise<void> {
  console.log("Calculating region overview...");

  const db = getFirestore();
  const locationsSnap = await db.collection("locations").get();

  const categoryTotals: CategoryCount = {};
  const cities = new Set<string>();

  locationsSnap.docs.forEach((doc) => {
    const data = doc.data();
    const category = data.category || "other";
    categoryTotals[category] = (categoryTotals[category] || 0) + 1;
    if (data.city) cities.add(data.city);
  });

  await db
    .collection("analytics")
    .doc("region_overview")
    .set(
      {
        totalLocations: locationsSnap.size,
        totalCities: cities.size,
        categoryTotals,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

  console.log(`Region overview updated: ${locationsSnap.size} locations`);
}

/**
 * Berechnet Statistiken pro Stadt
 */
export async function calculateCityStats(): Promise<void> {
  console.log("Calculating city stats...");

  const db = getFirestore();
  const locationsSnap = await db.collection("locations").get();

  // Gruppiere nach Stadt
  const cityData: Record<string, any[]> = {};

  locationsSnap.docs.forEach((doc) => {
    const data = doc.data();
    const city = findNearestCity(
      data.coordinates?.latitude,
      data.coordinates?.longitude,
      data.city
    );
    if (!cityData[city]) cityData[city] = [];
    cityData[city].push(data);
  });

  // Berechne Stats pro Stadt
  const batch = db.batch();

  for (const [cityName, locations] of Object.entries(cityData)) {
    const categoryDist: CategoryCount = {};
    let ratingSum = 0;
    let ratingCount = 0;

    locations.forEach((loc) => {
      const cat = loc.category || "other";
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
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = db
      .collection("analytics")
      .doc("city_stats")
      .collection("cities")
      .doc(cityName.toLowerCase().replace(/\s+/g, "-"));

    batch.set(docRef, stats);
  }

  await batch.commit();
  console.log(`City stats updated for ${Object.keys(cityData).length} cities`);
}

/**
 * Findet nächste bekannte Stadt basierend auf Koordinaten oder Name
 */
function findNearestCity(
  lat?: number,
  lng?: number,
  cityHint?: string
): string {
  // Zuerst Hint prüfen
  if (cityHint) {
    for (const city of Object.keys(CITIES)) {
      if (
        city.toLowerCase().includes(cityHint.toLowerCase()) ||
        cityHint.toLowerCase().includes(city.toLowerCase())
      ) {
        return city;
      }
    }
  }

  // Dann nach Distanz
  if (lat && lng) {
    let nearest = "Unbekannt";
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

  return "Unbekannt";
}

/**
 * Berechnet Coverage Score (0-1) basierend auf Mindest-Infrastruktur
 */
function calculateCoverageScore(
  categories: CategoryCount,
  population: number
): number {
  const pop10k = population / 10000;
  const scores: number[] = [];

  for (const [cat, minPer10k] of Object.entries(MIN_PER_10K)) {
    const actual = categories[cat] || 0;
    const expected = minPer10k * pop10k;
    if (expected > 0) {
      scores.push(Math.min(1, actual / expected));
    }
  }

  return scores.length > 0 ?
    scores.reduce((a, b) => a + b, 0) / scores.length :
    0.5;
}

/**
 * Berechnet Family Score (0-1)
 */
function calculateFamilyScore(
  categories: CategoryCount,
  population: number
): number {
  const familyCategories = [
    "playground",
    "pool",
    "zoo",
    "museum",
    "nature",
  ];
  const pop10k = population / 10000;

  let total = 0;
  familyCategories.forEach((cat) => {
    total += categories[cat] || 0;
  });

  // Ideal: 10 Familien-Orte pro 10k Einwohner
  const expected = 10 * pop10k;
  return Math.min(1, total / expected);
}
