import '../domain/event.dart';
import '../domain/notice.dart';
import 'events_data_source.dart';

/// Repository for Events and Notices
class EventsRepository {
  EventsRepository({EventsDataSource? dataSource})
      : _dataSource = dataSource ?? EventsDataSource();

  final EventsDataSource _dataSource;

  /// Get all events
  Future<List<MshEvent>> getAllEvents() async {
    return await _dataSource.loadEvents();
  }

  /// Get events filtered by date range
  Future<List<MshEvent>> getEventsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final allEvents = await getAllEvents();
    return allEvents.where((event) {
      return event.date.isAfter(start.subtract(const Duration(days: 1))) &&
          event.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get upcoming events (next 7 days)
  Future<List<MshEvent>> getUpcomingEvents() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return await getEventsByDateRange(start: now, end: nextWeek);
  }

  /// Get events by category
  Future<List<MshEvent>> getEventsByCategory(EventCategory category) async {
    final allEvents = await getAllEvents();
    return allEvents.where((event) => event.eventCategory == category).toList();
  }

  /// Get events by city
  Future<List<MshEvent>> getEventsByCity(String city) async {
    final allEvents = await getAllEvents();
    return allEvents.where((event) => event.city == city).toList();
  }

  /// Get all notices
  Future<List<MshNotice>> getAllNotices() async {
    return await _dataSource.loadNotices();
  }

  /// Get active notices only
  Future<List<MshNotice>> getActiveNotices() async {
    final allNotices = await getAllNotices();
    return allNotices.where((notice) => notice.isActive).toList();
  }

  /// Get critical notices
  Future<List<MshNotice>> getCriticalNotices() async {
    final activeNotices = await getActiveNotices();
    return activeNotices
        .where((notice) => notice.severity == NoticeSeverity.critical)
        .toList();
  }

  /// Get events metadata
  Future<Map<String, dynamic>?> getEventsMeta() async {
    return await _dataSource.getEventsMeta();
  }

  /// Get events statistics
  Future<Map<String, dynamic>?> getEventsStats() async {
    return await _dataSource.getEventsStats();
  }
}
