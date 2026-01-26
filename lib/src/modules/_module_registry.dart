import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/domain/map_item.dart';
import '../shared/domain/bounding_box.dart';

/// Abstrakte Basis für alle Module.
abstract class MshModule {
  String get moduleId;
  String get displayName;
  IconData get icon;
  Color get primaryColor;

  Future<void> initialize();
  Future<void> dispose();

  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region);
  Future<List<MapItem>> getItemsInRegion(BoundingBox region);

  Widget buildDetailView(BuildContext context, MapItem item);

  List<RouteBase> get additionalRoutes => [];
  List<FilterOption> get filterOptions => [];
}

/// Filter-Option
class FilterOption {

  const FilterOption({
    required this.id,
    required this.label,
    this.icon,
    required this.predicate,
  });
  final String id;
  final String label;
  final IconData? icon;
  final bool Function(MapItem) predicate;
}

/// Zentrale Registry
class ModuleRegistry {
  ModuleRegistry._();
  static final instance = ModuleRegistry._();

  final List<MshModule> _modules = [];
  final Set<String> _activeModuleIds = {};

  void register(MshModule module) {
    if (_modules.any((m) => m.moduleId == module.moduleId)) {
      throw StateError('Modul "${module.moduleId}" bereits registriert');
    }
    _modules.add(module);
  }

  List<MshModule> get all => List.unmodifiable(_modules);

  List<MshModule> get active =>
      _modules.where((m) => _activeModuleIds.contains(m.moduleId)).toList();

  void setActive(String moduleId, bool active) {
    if (active) {
      _activeModuleIds.add(moduleId);
    } else {
      _activeModuleIds.remove(moduleId);
    }
  }

  MshModule? getById(String moduleId) {
    return _modules.where((m) => m.moduleId == moduleId).firstOrNull;
  }

  List<RouteBase> collectAllRoutes() {
    return _modules.expand((m) => m.additionalRoutes).toList();
  }

  Future<void> initializeAll() async {
    for (final module in _modules) {
      await module.initialize();
      _activeModuleIds.add(module.moduleId);
    }
  }
}
