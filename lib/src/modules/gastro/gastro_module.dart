import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/gastro_repository.dart';
import 'domain/restaurant.dart';
import 'presentation/restaurant_detail.dart';

class GastroModule extends MshModule {

  GastroModule({GastroRepository? repository})
      : _repository = repository ?? GastroRepository();
  final GastroRepository _repository;

  @override
  String get moduleId => 'gastro';

  @override
  String get displayName => 'Gastronomie';

  @override
  IconData get icon => Icons.restaurant;

  @override
  Color get primaryColor => MshColors.categoryGastro;

  @override
  Future<void> initialize() async {
    // Optional: Initiale Daten laden
  }

  @override
  Future<void> dispose() async {}

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return _repository.watchRestaurantsInRegion(region);
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) {
    return _repository.getRestaurantsInRegion(region);
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is Restaurant) {
      return RestaurantDetailContent(restaurant: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
    FilterOption(
      id: 'has_menu',
      label: 'Mit Tagesangebot',
      icon: Icons.today,
      predicate: (item) => item is Restaurant && item.todaySpecial != null,
    ),
    FilterOption(
      id: 'type_imbiss',
      label: 'Nur Imbiss',
      icon: Icons.fastfood,
      predicate: (item) =>
          item is Restaurant && item.type == RestaurantType.imbiss,
    ),
  ];
}
