import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/engagement_repository.dart';
import '../domain/engagement_model.dart';

/// Repository Provider
final engagementRepositoryProvider = Provider((ref) => EngagementRepository());

/// Alle Engagement-Orte
final engagementPlacesProvider = FutureProvider<List<EngagementPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getPlaces();
});

/// Orte nach Typ
final engagementPlacesByTypeProvider = FutureProvider.family<List<EngagementPlace>, EngagementType>(
  (ref, type) {
    return ref.watch(engagementRepositoryProvider).getPlacesByType(type);
  },
);

/// Orte mit dringenden Bedürfnissen
final urgentEngagementPlacesProvider = FutureProvider<List<EngagementPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getUrgentPlaces();
});

/// Alle adoptierbaren Tiere
final adoptableAnimalsProvider = FutureProvider<List<AdoptableAnimalWithPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getAdoptableAnimals();
});

/// Adoptierbare Tiere nach Tierart
final adoptableAnimalsByTypeProvider = FutureProvider.family<List<AdoptableAnimalWithPlace>, AnimalType>(
  (ref, animalType) async {
    final all = await ref.watch(adoptableAnimalsProvider.future);
    return all.where((a) => a.animal.type == animalType).toList();
  },
);

/// Dringende Tiere (lange wartend oder als dringend markiert)
final urgentAnimalsProvider = FutureProvider<List<AdoptableAnimalWithPlace>>((ref) async {
  final all = await ref.watch(adoptableAnimalsProvider.future);
  return all.where((a) => a.animal.isUrgent || a.animal.isLongStay).toList();
});

/// Alle aktuellen Hilfsaufrufe
final currentNeedsProvider = FutureProvider<List<EngagementNeedWithPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getCurrentNeeds();
});

/// Dringende Hilfsaufrufe
final urgentNeedsProvider = FutureProvider<List<EngagementNeedWithPlace>>((ref) async {
  final all = await ref.watch(currentNeedsProvider.future);
  return all.where((n) =>
    n.need.urgency == UrgencyLevel.urgent ||
    n.need.urgency == UrgencyLevel.critical,
  ).toList();
});

/// Statistiken
final engagementStatsProvider = FutureProvider<EngagementStats>((ref) async {
  final places = await ref.watch(engagementPlacesProvider.future);
  final animals = await ref.watch(adoptableAnimalsProvider.future);
  final needs = await ref.watch(currentNeedsProvider.future);

  return EngagementStats(
    totalPlaces: places.length,
    urgentPlaces: places.where((p) => p.hasUrgentNeeds).length,
    totalAnimals: animals.length,
    urgentAnimals: animals.where((a) => a.animal.isUrgent || a.animal.isLongStay).length,
    totalNeeds: needs.length,
    urgentNeeds: needs.where((n) =>
      n.need.urgency == UrgencyLevel.urgent ||
      n.need.urgency == UrgencyLevel.critical,
    ).length,
    byType: {
      for (final type in EngagementType.values)
        type: places.where((p) => p.type == type).length,
    },
  );
});

class EngagementStats {

  EngagementStats({
    required this.totalPlaces,
    required this.urgentPlaces,
    required this.totalAnimals,
    required this.urgentAnimals,
    required this.totalNeeds,
    required this.urgentNeeds,
    required this.byType,
  });
  final int totalPlaces;
  final int urgentPlaces;
  final int totalAnimals;
  final int urgentAnimals;
  final int totalNeeds;
  final int urgentNeeds;
  final Map<EngagementType, int> byType;
}
