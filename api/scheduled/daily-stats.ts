/**
 * Vercel Cron Job: Tägliche Statistik-Updates (3 Uhr nachts)
 */

import type {VercelRequest, VercelResponse} from "@vercel/node";
import {getFirebaseApp} from "../utils/firebase";
import {calculateRegionOverview, calculateCityStats} from "../analytics/aggregation";
import {detectGaps} from "../analytics/gaps";
import {generateInsights} from "../analytics/insights";

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

    console.log("Starting daily stats update...");

    // Alle Analytics berechnen
    await calculateRegionOverview();
    await calculateCityStats();
    await detectGaps();
    await generateInsights();

    console.log("Daily stats update complete");

    return res.status(200).json({
      success: true,
      message: "Daily stats updated",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Daily stats update failed:", error);

    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    });
  }
}
