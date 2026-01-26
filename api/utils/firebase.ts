/**
 * Firebase Admin Initialisierung für Vercel
 */

import * as admin from "firebase-admin";

// Singleton für Firebase Admin
let firebaseApp: admin.app.App | undefined;

/**
 * Initialisiert oder gibt existierende Firebase Admin App zurück
 */
export function getFirebaseApp(): admin.app.App {
  if (firebaseApp) {
    return firebaseApp;
  }

  // Service Account aus Environment Variable (JSON String)
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;

  if (!serviceAccountJson) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT environment variable is required"
    );
  }

  try {
    const serviceAccount = JSON.parse(serviceAccountJson);

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID || "lunch-radar-5d984",
    });

    return firebaseApp;
  } catch (error) {
    console.error("Failed to initialize Firebase Admin:", error);
    throw error;
  }
}

/**
 * Gibt Firestore Client zurück
 */
export function getFirestore(): admin.firestore.Firestore {
  const app = getFirebaseApp();
  return app.firestore();
}
