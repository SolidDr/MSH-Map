import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/leisure_repository.dart';
import 'domain/pool.dart';
import 'presentation/pool_detail.dart';

/// Modul für Freizeit-Einrichtungen (Schwimmbäder, etc.)
class LeisureModule extends MshModule {
  LeisureModule({LeisureRepository? repository})
      : _repository = repository ?? LeisureRepository();

  final LeisureRepository _repository;
  List<Pool>? _cachedPools;

  @override
  String get moduleId => 'leisure';

  @override
  String get displayName => 'Freizeit';

  @override
  IconData get icon => Icons.pool;

  @override
  Color get primaryColor => MshColors.categoryPool;

  @override
  Future<void> initialize() async {
    _cachedPools = await _repository.loadPools();
  }

  @override
  Future<void> dispose() async {
    _cachedPools = null;
    _repository.clearCache();
  }

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) async* {
    final items = await getItemsInRegion(region);
    yield items;
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    _cachedPools ??= await _repository.loadPools();

    return _cachedPools!
        .where((pool) => region.contains(pool.coordinates))
        .cast<MapItem>()
        .toList();
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is Pool) {
      return PoolDetailContent(pool: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        FilterOption(
          id: 'pool_indoor',
          label: 'Hallenbad',
          icon: Icons.pool,
          predicate: (item) => item is Pool && item.poolType == PoolType.indoor,
        ),
        FilterOption(
          id: 'pool_outdoor',
          label: 'Freibad',
          icon: Icons.wb_sunny,
          predicate: (item) =>
              item is Pool && item.poolType == PoolType.outdoor,
        ),
        FilterOption(
          id: 'pool_barrier_free',
          label: 'Barrierefrei',
          icon: Icons.accessible,
          predicate: (item) => item is Pool && item.isBarrierFree,
        ),
        FilterOption(
          id: 'pool_family',
          label: 'Familienfreundlich',
          icon: Icons.family_restroom,
          predicate: (item) => item is Pool && item.familyFriendly,
        ),
      ];
}
