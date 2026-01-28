import '../domain/wanderweg_category.dart';
import '../domain/wanderweg_route.dart';
import 'trails/josephskreuz_rundweg.dart';
import 'trails/karstwanderweg.dart';
import 'trails/selketal_stieg.dart';
import 'trails/stolberg_burgweg.dart';
import 'trails/thyra_talweg.dart';

/// Repository für alle Wanderwege
class WanderwegeRepository {
  /// Alle verfügbaren Wanderwege
  static final List<WanderwegRoute> allRoutes = [
    karstwanderwegRoute,
    selketalStiegRoute,
    josephskreuzRundwegRoute,
    stolbergBurgwegRoute,
    thyraTalwegRoute,
  ];

  /// Wanderweg nach ID finden
  static WanderwegRoute? byId(String id) {
    try {
      return allRoutes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Wanderwege nach Kategorie filtern
  static List<WanderwegRoute> byCategory(WanderwegCategory category) {
    return allRoutes.where((r) => r.category == category).toList();
  }

  /// Wanderwege nach Schwierigkeit filtern
  static List<WanderwegRoute> byDifficulty(TrailDifficulty difficulty) {
    return allRoutes.where((r) => r.difficulty == difficulty).toList();
  }

  /// Nur verifizierte Wanderwege
  static List<WanderwegRoute> get verifiedOnly {
    return allRoutes.where((r) => r.status == TrailStatus.verified).toList();
  }

  /// Alle verfügbaren Kategorien
  static List<WanderwegCategory> get availableCategories {
    return allRoutes.map((r) => r.category).toSet().toList();
  }

  /// Anzahl pro Kategorie
  static Map<WanderwegCategory, int> get countByCategory {
    final counts = <WanderwegCategory, int>{};
    for (final route in allRoutes) {
      counts[route.category] = (counts[route.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Gesamtkilometer aller Wanderwege
  static double get totalKilometers {
    return allRoutes.fold(0.0, (sum, r) => sum + r.lengthKm);
  }

  /// Wanderwege sortiert nach Länge
  static List<WanderwegRoute> get sortedByLength {
    return List.from(allRoutes)..sort((a, b) => a.lengthKm.compareTo(b.lengthKm));
  }

  /// Wanderwege sortiert nach Schwierigkeit
  static List<WanderwegRoute> get sortedByDifficulty {
    return List.from(allRoutes)
      ..sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
  }

  /// Wanderwege sortiert nach Höhenmetern
  static List<WanderwegRoute> get sortedByElevation {
    return List.from(allRoutes)
      ..sort((a, b) => (b.elevationGain ?? 0).compareTo(a.elevationGain ?? 0));
  }
}
