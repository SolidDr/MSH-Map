import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/domain/bounding_box.dart';
import '../domain/restaurant.dart';

class GastroRepository {

  GastroRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('restaurants');

  /// Stream von Restaurants in Region
  Stream<List<Restaurant>> watchRestaurantsInRegion(BoundingBox region) {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Restaurant.fromFirestore(doc.id, doc.data()))
          .where((r) => region.contains(r.coordinates))
          .toList();
    });
  }

  /// Einmalige Abfrage
  Future<List<Restaurant>> getRestaurantsInRegion(BoundingBox region) async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Restaurant.fromFirestore(doc.id, doc.data()))
        .where((r) => region.contains(r.coordinates))
        .toList();
  }

  /// Restaurant nach ID
  Future<Restaurant?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Restaurant.fromFirestore(doc.id, doc.data()!);
  }

  /// Tagesmenü aktualisieren
  Future<void> updateTodayMenu(String id, String special, double price) async {
    await _collection.doc(id).update({
      'todaySpecial': special,
      'todayPrice': price,
      'lastMenuUpdate': FieldValue.serverTimestamp(),
    });
  }
}
