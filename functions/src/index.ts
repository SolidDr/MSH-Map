/**
 * MSH Map Cloud Functions
 * Firebase Functions für Daten-Aggregation, Analytics und Insights
 */

import * as admin from "firebase-admin";

// Firebase Admin initialisieren
admin.initializeApp();

// Scheduled Functions
export {updateDailyStats, updateWeeklyReport} from "./triggers/scheduled";

// Firestore Trigger Functions
export {
  onLocationCreated,
  onLocationUpdated,
  onLocationDeleted,
} from "./triggers/onLocationChange";

// HTTP Functions (für manuelle Trigger)
export {recalculateAll} from "./analytics/aggregation";
