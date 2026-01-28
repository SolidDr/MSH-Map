import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dish_repository.dart';
import '../domain/dish_model.dart';

/// Provider for watching all menus
final menusStreamProvider = StreamProvider<List<MenuModel>>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return repository.watchAllMenus();
});

/// Provider for watching today's menus
final todaysMenusStreamProvider = StreamProvider<List<MenuModel>>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return repository.watchTodaysMenus();
});
