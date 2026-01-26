/**
 * Firestore Trigger Functions für Location-Änderungen
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Trigger: Neue Location erstellt
 */
export const onLocationCreated = functions.firestore
  .document("locations/{locationId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    // Kategorie-Counter erhöhen
    const category = data.category || "other";
    await db
      .collection("analytics")
      .doc("region_overview")
      .update({
        [`categoryTotals.${category}`]:
          admin.firestore.FieldValue.increment(1),
        totalLocations: admin.firestore.FieldValue.increment(1),
      });

    console.log(`Location created: ${data.name} (${category})`);
  });

/**
 * Trigger: Location aktualisiert
 */
export const onLocationUpdated = functions.firestore
  .document("locations/{locationId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Kategorie geändert?
    if (before.category !== after.category) {
      await db
        .collection("analytics")
        .doc("region_overview")
        .update({
          [`categoryTotals.${before.category}`]:
            admin.firestore.FieldValue.increment(-1),
          [`categoryTotals.${after.category}`]:
            admin.firestore.FieldValue.increment(1),
        });

      console.log(
        `Location category changed: ${before.category} -> ${after.category}`
      );
    }

    // View-Count erhöht? (Popularity Update)
    if ((after.viewCount || 0) > (before.viewCount || 0)) {
      // Könnte Popularity-Score neu berechnen
      // TODO: Implement popularity scoring
    }
  });

/**
 * Trigger: Location gelöscht
 */
export const onLocationDeleted = functions.firestore
  .document("locations/{locationId}")
  .onDelete(async (snap, context) => {
    const data = snap.data();

    // Kategorie-Counter verringern
    const category = data.category || "other";
    await db
      .collection("analytics")
      .doc("region_overview")
      .update({
        [`categoryTotals.${category}`]:
          admin.firestore.FieldValue.increment(-1),
        totalLocations: admin.firestore.FieldValue.increment(-1),
      });

    console.log(`Location deleted: ${data.name} (${category})`);
  });
