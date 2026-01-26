const admin = require('firebase-admin');
const fs = require('fs');

// Service Account laden
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importData() {
  console.log('Reading msh_data_seed.json...');
  const rawData = fs.readFileSync('msh_data_seed.json');
  const json = JSON.parse(rawData);
  const data = json.data;

  console.log(`Found ${data.length} items to import.\n`);

  const batch = db.batch();
  let count = 0;

  for (const item of data) {
    const docRef = db.collection('pois').doc(item.id);

    const doc = {
      name: item.name,
      description: item.description,
      category: item.category,
      address: item.address,
      city: item.city,
      location: new admin.firestore.GeoPoint(item.latitude, item.longitude),
      tags: item.tags || [],
      website: item.website || null,
      is_free: item.is_free || false,
      is_indoor: item.is_indoor || false,
      is_outdoor: item.is_outdoor || true,
      is_barrier_free: item.is_barrier_free || false,
      age_range: item.age_range || 'alle',
      activity_type: item.activity_type,
      opening_hours: item.opening_hours || null,
      price_info: item.price_info || null,
      contact_phone: item.contact_phone || null,
      contact_email: item.contact_email || null,
      facilities: item.facilities || [],
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Remove null values
    Object.keys(doc).forEach(key => doc[key] === null && delete doc[key]);

    batch.set(docRef, doc);
    count++;
    console.log(`${count}. ${item.name}`);
  }

  console.log('\nCommitting batch...');
  await batch.commit();
  console.log('\n✅ Import complete!');
  console.log(`Imported ${count} items.`);
  process.exit(0);
}

importData().catch(err => {
  console.error('ERROR:', err);
  process.exit(1);
});
