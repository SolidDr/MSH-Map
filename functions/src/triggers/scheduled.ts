/**
 * Scheduled (Cron) Trigger Functions
 */

import * as functions from "firebase-functions";
import {
  calculateRegionOverview,
  calculateCityStats,
} from "../analytics/aggregation";
import {detectGaps} from "../analytics/gaps";
import {generateInsights} from "../analytics/insights";

/**
 * Tägliche Aktualisierung um 3 Uhr nachts (Berlin Zeit)
 */
export const updateDailyStats = functions.pubsub
  .schedule("0 3 * * *")
  .timeZone("Europe/Berlin")
  .onRun(async () => {
    console.log("Starting daily stats update...");

    try {
      await calculateRegionOverview();
      await calculateCityStats();
      await detectGaps();
      await generateInsights();

      console.log("Daily stats update complete");
    } catch (error) {
      console.error("Daily stats update failed:", error);
      throw error;
    }
  });

/**
 * Wöchentlicher Report (Sonntag 6 Uhr)
 */
export const updateWeeklyReport = functions.pubsub
  .schedule("0 6 * * 0")
  .timeZone("Europe/Berlin")
  .onRun(async () => {
    console.log("Generating weekly report...");

    // TODO: Erweiterten Wochen-Report generieren
    // - Vergleich zur Vorwoche
    // - Top-Veränderungen
    // - Neue Locations

    console.log("Weekly report complete");
  });
