/**
 * Vercel API Endpoint: Manuelle Neuberechnung aller Statistiken
 */

import type {VercelRequest, VercelResponse} from "@vercel/node";
import {getFirebaseApp} from "./utils/firebase";
import {calculateRegionOverview, calculateCityStats} from "./analytics/aggregation";
import {detectGaps} from "./analytics/gaps";
import {generateInsights} from "./analytics/insights";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  // CORS Headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  try {
    // Firebase initialisieren
    getFirebaseApp();

    console.log("Starting full recalculation...");

    // Alle Analytics neu berechnen
    await calculateRegionOverview();
    await calculateCityStats();
    await detectGaps();
    await generateInsights();

    console.log("Recalculation complete");

    return res.status(200).json({
      success: true,
      message: "All analytics recalculated successfully",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Recalculation failed:", error);

    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    });
  }
}
