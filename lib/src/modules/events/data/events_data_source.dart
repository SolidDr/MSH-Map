import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../domain/event.dart';
import '../domain/notice.dart';

/// Data Source for loading Events and Notices from JSON files
class EventsDataSource {
  static const _eventsPath = 'data/events/events_current.json';
  static const _noticesPath = 'data/notices/notices_current.json';

  /// Load all events from JSON file
  Future<List<MshEvent>> loadEvents() async {
    try {
      final jsonString = await rootBundle.loadString(_eventsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final eventsList = jsonData['events'] as List<dynamic>;

      return eventsList
          .map((e) => MshEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading events: $e');
      return [];
    }
  }

  /// Load all notices from JSON file
  Future<List<MshNotice>> loadNotices() async {
    try {
      final jsonString = await rootBundle.loadString(_noticesPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final noticesList = jsonData['notices'] as List<dynamic>;

      return noticesList
          .map((e) => MshNotice.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading notices: $e');
      return [];
    }
  }

  /// Get events metadata
  Future<Map<String, dynamic>?> getEventsMeta() async {
    try {
      final jsonString = await rootBundle.loadString(_eventsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return jsonData['meta'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error loading events metadata: $e');
      return null;
    }
  }

  /// Get events statistics
  Future<Map<String, dynamic>?> getEventsStats() async {
    try {
      final jsonString = await rootBundle.loadString(_eventsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return jsonData['stats'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error loading events stats: $e');
      return null;
    }
  }
}
