/**
 * Vercel Cron Job: Wöchentlicher Report (Sonntags 6 Uhr)
 */

import type {VercelRequest, VercelResponse} from "@vercel/node";
import {getFirebaseApp, getFirestore} from "../utils/firebase";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  // Vercel Cron Secret validieren
  const authHeader = req.headers.authorization;
  const cronSecret = process.env.CRON_SECRET;

  if (cronSecret && authHeader !== `Bearer ${cronSecret}`) {
    return res.status(401).json({error: "Unauthorized"});
  }

  try {
    // Firebase initialisieren
    getFirebaseApp();
    const db = getFirestore();

    console.log("Starting weekly report generation...");

    // Overview-Daten laden
    const overviewDoc = await db
      .collection("analytics")
      .doc("region_overview")
      .get();
    const overview = overviewDoc.data();

    // Stadt-Stats laden
    const cityStatsSnap = await db
      .collection("analytics")
      .doc("city_stats")
      .collection("cities")
      .get();

    // Gaps laden
    const gapsSnap = await db
      .collection("analytics")
      .doc("gaps")
      .collection("items")
      .get();

    const report = {
      generatedAt: new Date().toISOString(),
      overview: {
        totalLocations: overview?.totalLocations || 0,
        totalCities: overview?.totalCities || 0,
        categoryTotals: overview?.categoryTotals || {},
      },
      cities: cityStatsSnap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })),
      gaps: gapsSnap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })),
    };

    // Report speichern
    await db.collection("reports").add({
      type: "weekly",
      ...report,
    });

    console.log("Weekly report generated");

    return res.status(200).json({
      success: true,
      message: "Weekly report generated",
      summary: {
        locations: report.overview.totalLocations,
        cities: report.cities.length,
        gaps: report.gaps.length,
      },
    });
  } catch (error) {
    console.error("Weekly report generation failed:", error);

    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    });
  }
}
