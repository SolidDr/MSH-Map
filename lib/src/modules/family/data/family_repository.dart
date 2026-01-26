import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/domain/bounding_box.dart';
import '../domain/poi.dart';

class FamilyRepository {
  FamilyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('pois');

  /// Stream von POIs in Region
  Stream<List<Poi>> watchPoisInRegion(BoundingBox region) {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Poi.fromFirestore(doc.id, doc.data()))
          .where((poi) => region.contains(poi.coordinates))
          .toList();
    });
  }

  /// Einmalige Abfrage
  Future<List<Poi>> getPoisInRegion(BoundingBox region) async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Poi.fromFirestore(doc.id, doc.data()))
        .where((poi) => region.contains(poi.coordinates))
        .toList();
  }

  /// POI nach ID
  Future<Poi?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Poi.fromFirestore(doc.id, doc.data()!);
  }

  /// POI erstellen/aktualisieren
  Future<void> save(Poi poi) async {
    await _collection.doc(poi.id).set(poi.toFirestore());
  }

  /// POI löschen
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
