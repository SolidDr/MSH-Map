import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/event.dart';
import '../domain/notice.dart';
import 'events_repository.dart';

/// Repository Provider
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository();
});

/// All Events Provider
final allEventsProvider = FutureProvider<List<MshEvent>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getAllEvents();
});

/// Upcoming Events Provider (next 7 days)
final upcomingEventsProvider = FutureProvider<List<MshEvent>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getUpcomingEvents();
});

/// Events by Category Provider
final eventsByCategoryProvider =
    FutureProvider.family<List<MshEvent>, EventCategory>((ref, category) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getEventsByCategory(category);
});

/// Events by City Provider
final eventsByCityProvider =
    FutureProvider.family<List<MshEvent>, String>((ref, city) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getEventsByCity(city);
});

/// All Notices Provider
final allNoticesProvider = FutureProvider<List<MshNotice>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getAllNotices();
});

/// Active Notices Provider
final activeNoticesProvider = FutureProvider<List<MshNotice>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getActiveNotices();
});

/// Critical Notices Provider
final criticalNoticesProvider = FutureProvider<List<MshNotice>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getCriticalNotices();
});

/// Events Metadata Provider
final eventsMetaProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getEventsMeta();
});

/// Events Statistics Provider
final eventsStatsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return await repository.getEventsStats();
});
