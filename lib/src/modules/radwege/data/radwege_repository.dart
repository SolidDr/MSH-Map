import '../domain/radweg_category.dart';
import '../domain/radweg_route.dart';
import 'routes/himmelsscheiben_route.dart';
import 'routes/kupferspuren_route.dart';
import 'routes/kyffhaeuser_route.dart';
import 'routes/lutherweg_route.dart';
import 'routes/romanik_route.dart';
import 'routes/saale_harz_route.dart';
import 'routes/salzstrasse_route.dart';
import 'routes/suesser_see_route.dart';
import 'routes/wipper_route.dart';

/// Repository für alle Radwege in MSH
class RadwegeRepository {
  RadwegeRepository._();

  /// Alle verfügbaren Radwege
  static final List<RadwegRoute> allRoutes = [
    kupferspurenRoute,
    romanikRoute,
    saaleHarzRoute,
    kyffhaeuserRoute,
    wipperRoute,
    himmelsscheibenRoute,
    salzstrasseRoute,
    suesserSeeRoute,
    lutherwegRoute,
  ];

  /// Radwege nach Kategorie filtern
  static List<RadwegRoute> byCategory(RadwegCategory category) {
    return allRoutes.where((r) => r.category == category).toList();
  }

  /// Radweg nach ID finden
  static RadwegRoute? byId(String id) {
    try {
      return allRoutes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Alle Kategorien die Radwege haben
  static List<RadwegCategory> get availableCategories {
    return RadwegCategory.values
        .where((cat) => allRoutes.any((r) => r.category == cat))
        .toList();
  }

  /// Anzahl Radwege pro Kategorie
  static Map<RadwegCategory, int> get countByCategory {
    final counts = <RadwegCategory, int>{};
    for (final route in allRoutes) {
      counts[route.category] = (counts[route.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Gesamtkilometer aller Radwege
  static double get totalKilometers {
    return allRoutes.fold(0, (sum, r) => sum + r.lengthKm);
  }
}
