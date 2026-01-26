import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dish.dart';

/// Provider for the menu repository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

/// Repository for menu operations
class MenuRepository {

  MenuRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('menus');

  /// Get all menus for a merchant
  Stream<List<MenuModel>> watchMenusForMerchant(String merchantId) {
    return _collection
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(MenuModel.fromFirestore).toList(),);
  }

  /// Get today's menus
  Stream<List<MenuModel>> watchTodayMenus() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(MenuModel.fromFirestore).toList(),);
  }

  /// Save a new menu
  Future<MenuModel> saveMenu({
    required String merchantId,
    required String merchantName,
    required List<DishModel> dishes,
    required DateTime date,
    String? imageUrl,
  }) async {
    final docRef = _collection.doc();
    final menu = MenuModel(
      id: docRef.id,
      merchantId: merchantId,
      merchantName: merchantName,
      dishes: dishes,
      date: date,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await docRef.set(menu.toFirestore());
    return menu;
  }

  /// Update menu active status
  Future<void> setMenuActive(String menuId, bool isActive) async {
    await _collection.doc(menuId).update({'isActive': isActive});
  }

  /// Delete a menu
  Future<void> deleteMenu(String menuId) async {
    await _collection.doc(menuId).delete();
  }

  /// Get menu by ID
  Future<MenuModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return MenuModel.fromFirestore(doc);
  }
}
