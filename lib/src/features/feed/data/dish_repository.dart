import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/dish_model.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for the menu repository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(ref.watch(firestoreProvider));
});

/// Repository for menu operations with Firestore
class MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepository(this._firestore);

  /// Collection reference for menus
  CollectionReference<Map<String, dynamic>> get _menusCollection =>
      _firestore.collection(AppConstants.menusCollection);

  /// Save a new menu to Firestore
  Future<MenuModel> saveMenu({
    required String merchantId,
    required String merchantName,
    required List<DishModel> dishes,
    required DateTime date,
    String? imageUrl,
  }) async {
    final docRef = _menusCollection.doc();

    final menu = MenuModel(
      id: docRef.id,
      merchantId: merchantId,
      merchantName: merchantName,
      dishes: dishes,
      date: date,
      imageUrl: imageUrl,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await docRef.set(menu.toFirestore());

    return menu;
  }

  /// Get all active menus for today
  Stream<List<MenuModel>> watchTodaysMenus() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _menusCollection
        .where('isActive', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList());
  }

  /// Get all active menus (for testing without date filter)
  Stream<List<MenuModel>> watchAllMenus() {
    return _menusCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.defaultPageSize)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList());
  }

  /// Get menus for a specific merchant
  Stream<List<MenuModel>> watchMerchantMenus(String merchantId) {
    return _menusCollection
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('date', descending: true)
        .limit(AppConstants.defaultPageSize)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList());
  }

  /// Deactivate a menu
  Future<void> deactivateMenu(String menuId) async {
    await _menusCollection.doc(menuId).update({'isActive': false});
  }

  /// Delete a menu
  Future<void> deleteMenu(String menuId) async {
    await _menusCollection.doc(menuId).delete();
  }
}
