/**
 * Firebase Firestore Cleanup Script
 * Entfernt alle nicht-verifizierten Locations aus Firebase
 *
 * Usage: node firebase_cleanup.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Firebase initialisieren mit Application Default Credentials
// Entweder GOOGLE_APPLICATION_CREDENTIALS env var setzen
// oder Service Account Key hier laden
const serviceAccountPath = path.join(__dirname, '../../lunch-radar-firebase-adminsdk.json');

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} else {
  console.log('[!] Kein Service Account Key gefunden.');
  console.log('    Versuche Application Default Credentials...');
  admin.initializeApp({
    projectId: 'lunch-radar-5d984'
  });
}

const db = admin.firestore();

// Lade die bereinigte Locations-Liste
const cleanedDataPath = path.join(__dirname, '../output/merged/msh_firestore_CLEANED.json');
const cleanedData = JSON.parse(fs.readFileSync(cleanedDataPath, 'utf8'));
const validIds = new Set(Object.keys(cleanedData.locations || {}));

console.log(`[>] ${validIds.size} verifizierte Location-IDs geladen`);

// Bekannte Fake-IDs (aus fake_checker.py)
const KNOWN_FAKES = [
  'kinderland-indoor',
  'cafe-rosenduft',
  'kletterwald-questenberg',
  'fussballgolf-questenberg',
  'erlebnisbauernhof-stolberg',
  'naturbad-questenberg',
  'minigolf-sangerhausen',
];

async function cleanupCollection(collectionName) {
  console.log(`\n[>] Bereinige Collection: ${collectionName}`);

  const snapshot = await db.collection(collectionName).get();
  console.log(`    ${snapshot.size} Dokumente gefunden`);

  let deleted = 0;
  let kept = 0;

  const batch = db.batch();
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    const id = doc.id;
    const data = doc.data();
    const name = data.name || id;

    // Pruefen ob Fake
    const isFake = KNOWN_FAKES.includes(id);
    const isValid = validIds.has(id);

    if (isFake || !isValid) {
      console.log(`    [DEL] ${name} (${id})`);
      batch.delete(doc.ref);
      deleted++;
      batchCount++;

      // Batch committen alle 400 Operationen (Firestore Limit: 500)
      if (batchCount >= 400) {
        await batch.commit();
        batchCount = 0;
      }
    } else {
      kept++;
    }
  }

  // Restliche Batch committen
  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(`    [OK] ${kept} behalten, ${deleted} geloescht`);
  return { kept, deleted };
}

async function main() {
  console.log('================================================');
  console.log('FIREBASE FIRESTORE CLEANUP');
  console.log('================================================');
  console.log('');

  try {
    // Locations Collection bereinigen
    const locResult = await cleanupCollection('locations');

    // POIs Collection bereinigen (falls vorhanden)
    const poisResult = await cleanupCollection('pois');

    console.log('\n================================================');
    console.log('ERGEBNIS');
    console.log('================================================');
    console.log(`Locations: ${locResult.kept} behalten, ${locResult.deleted} geloescht`);
    console.log(`POIs:      ${poisResult.kept} behalten, ${poisResult.deleted} geloescht`);
    console.log('================================================');
    console.log('[OK] Firebase Cleanup abgeschlossen!');

  } catch (error) {
    console.error('[X] Fehler:', error.message);
    if (error.message.includes('Could not load the default credentials')) {
      console.log('\n[!] HINWEIS: Firebase Authentifizierung erforderlich.');
      console.log('    Option 1: Exportiere Service Account Key nach lunch-radar-firebase-adminsdk.json');
      console.log('    Option 2: Fuehre "gcloud auth application-default login" aus');
      console.log('    Option 3: Setze GOOGLE_APPLICATION_CREDENTIALS env var');
    }
    process.exit(1);
  }

  process.exit(0);
}

main();
