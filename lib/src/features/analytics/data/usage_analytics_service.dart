import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service für anonymisierte Nutzungsanalysen
///
/// Erfasst aggregierte Nutzungsmuster ohne personenbezogene Daten:
/// - Welche Module werden genutzt (Gastro, Events, Gesundheit, etc.)
/// - Welche POI-Kategorien werden angesehen
/// - Wann sind Nutzer aktiv (Tageszeit, Wochentag)
/// - Welche Aktionen werden durchgeführt (Map-Klicks, Filter, Suche)
class UsageAnalyticsService {
  UsageAnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionPath = 'analytics';
  static const String _usageDocId = 'usage_stats';
  static const String _sessionKey = 'analytics_session_date';

  final FirebaseFirestore _firestore;

  /// Trackt einen Modul-Besuch (z.B. "events", "health", "gastro")
  Future<void> trackModuleVisit(String moduleId) async {
    await _incrementCounter('modules', moduleId);
  }

  /// Trackt einen POI-Klick mit Kategorie
  Future<void> trackPoiClick(String category) async {
    await _incrementCounter('poi_clicks', category);
    await _trackHourlyActivity();
  }

  /// Trackt einen POI-Klick mit spezifischer ID für Popularity-Berechnung
  Future<void> trackPoiClickById(String poiId, String category) async {
    await _incrementCounter('poi_clicks', category);
    await _incrementCounter('poi_clicks_by_id', poiId);
    await _trackHourlyActivity();
  }

  /// Holt die Klick-Statistiken pro POI-ID
  Future<Map<String, int>> getPoiClickStats() async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_usageDocId)
          .get();

      if (!doc.exists) {
        return {};
      }

      final data = doc.data()!;
      return UsageStats._toIntMap(data['poi_clicks_by_id']);
    } on Exception {
      return {};
    }
  }

  /// Stream für POI-Klick-Updates
  Stream<Map<String, int>> watchPoiClickStats() {
    return _firestore
        .collection(_collectionPath)
        .doc(_usageDocId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return <String, int>{};
      return UsageStats._toIntMap(doc.data()!['poi_clicks_by_id']);
    });
  }

  /// Trackt eine Suchanfrage
  Future<void> trackSearch() async {
    await _incrementCounter('actions', 'search');
  }

  /// Trackt einen Filter-Einsatz
  Future<void> trackFilterUse(String filterId) async {
    await _incrementCounter('filters', filterId);
  }

  /// Trackt eine Bewertungsabgabe
  Future<void> trackRatingSubmitted() async {
    await _incrementCounter('actions', 'rating_submitted');
  }

  /// Trackt stündliche Aktivität (anonymisiert)
  Future<void> _trackHourlyActivity() async {
    final hour = DateTime.now().hour;
    final weekday = DateTime.now().weekday; // 1 = Mo, 7 = So

    await _incrementCounter('hourly_activity', hour.toString().padLeft(2, '0'));
    await _incrementCounter('weekday_activity', weekday.toString());
  }

  /// Inkrementiert einen Zähler atomar
  Future<void> _incrementCounter(String category, String key) async {
    try {
      final docRef = _firestore.collection(_collectionPath).doc(_usageDocId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          transaction.set(docRef, {
            category: {key: 1},
            'last_updated': FieldValue.serverTimestamp(),
          });
        } else {
          final data = doc.data()!;
          final categoryData = data[category] as Map<String, dynamic>? ?? {};
          final updatedCategory = Map<String, dynamic>.from(categoryData);
          updatedCategory[key] = ((updatedCategory[key] as int?) ?? 0) + 1;

          transaction.update(docRef, {
            category: updatedCategory,
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      });
    } on Exception {
      // Fehler beim Tracking ignorieren - keine App-Auswirkung
    }
  }

  /// Holt alle Nutzungsstatistiken
  Future<UsageStats> getStats() async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_usageDocId)
          .get();

      if (!doc.exists) {
        return UsageStats.empty();
      }

      return UsageStats.fromFirestore(doc.data()!);
    } on Exception {
      return UsageStats.empty();
    }
  }

  /// Stream für Echtzeit-Updates
  Stream<UsageStats> watchStats() {
    return _firestore
        .collection(_collectionPath)
        .doc(_usageDocId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return UsageStats.empty();
      return UsageStats.fromFirestore(doc.data()!);
    });
  }

  /// Prüft ob Session-Tracking heute schon erfolgt ist
  Future<bool> _isNewSession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastSession = prefs.getString(_sessionKey);

    if (lastSession != today) {
      await prefs.setString(_sessionKey, today);
      return true;
    }
    return false;
  }

  /// Trackt einen neuen Session-Start (einmal pro Tag)
  Future<void> trackSessionStart() async {
    if (await _isNewSession()) {
      await _incrementCounter('sessions', _getTodayKey());
      await _trackHourlyActivity();
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

/// Aggregierte Nutzungsstatistiken
class UsageStats {
  const UsageStats({
    required this.moduleVisits,
    required this.poiClicks,
    required this.filterUsage,
    required this.hourlyActivity,
    required this.weekdayActivity,
    required this.actions,
    required this.sessions,
    this.lastUpdated,
  });

  factory UsageStats.empty() => const UsageStats(
        moduleVisits: {},
        poiClicks: {},
        filterUsage: {},
        hourlyActivity: {},
        weekdayActivity: {},
        actions: {},
        sessions: {},
      );

  factory UsageStats.fromFirestore(Map<String, dynamic> data) {
    return UsageStats(
      moduleVisits: _toIntMap(data['modules']),
      poiClicks: _toIntMap(data['poi_clicks']),
      filterUsage: _toIntMap(data['filters']),
      hourlyActivity: _toIntMap(data['hourly_activity']),
      weekdayActivity: _toIntMap(data['weekday_activity']),
      actions: _toIntMap(data['actions']),
      sessions: _toIntMap(data['sessions']),
      lastUpdated: (data['last_updated'] as Timestamp?)?.toDate(),
    );
  }

  final Map<String, int> moduleVisits;
  final Map<String, int> poiClicks;
  final Map<String, int> filterUsage;
  final Map<String, int> hourlyActivity;
  final Map<String, int> weekdayActivity;
  final Map<String, int> actions;
  final Map<String, int> sessions;
  final DateTime? lastUpdated;

  /// Gesamtzahl aller POI-Klicks
  int get totalPoiClicks => poiClicks.values.fold(0, (a, b) => a + b);

  /// Gesamtzahl aller Modul-Besuche
  int get totalModuleVisits => moduleVisits.values.fold(0, (a, b) => a + b);

  /// Gesamtzahl aller Sessions
  int get totalSessions => sessions.values.fold(0, (a, b) => a + b);

  /// Top N Module nach Besuchen
  List<MapEntry<String, int>> topModules(int n) {
    final sorted = moduleVisits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Top N Kategorien nach Klicks
  List<MapEntry<String, int>> topCategories(int n) {
    final sorted = poiClicks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Aktivste Stunden (sortiert)
  List<MapEntry<String, int>> mostActiveHours() {
    final sorted = hourlyActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  /// Aktivitäts-Verteilung pro Wochentag
  Map<String, int> get weekdayDistribution {
    final result = <String, int>{};
    for (var i = 1; i <= 7; i++) {
      result[_weekdayName(i)] = weekdayActivity[i.toString()] ?? 0;
    }
    return result;
  }

  /// Peak-Stunde (aktivste Zeit)
  String? get peakHour {
    if (hourlyActivity.isEmpty) return null;
    final sorted = hourlyActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final hour = int.tryParse(sorted.first.key) ?? 0;
    return '$hour:00 - ${hour + 1}:00 Uhr';
  }

  /// Aktivster Wochentag
  String? get peakWeekday {
    if (weekdayActivity.isEmpty) return null;
    final sorted = weekdayActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final day = int.tryParse(sorted.first.key) ?? 1;
    return _weekdayName(day);
  }

  static Map<String, int> _toIntMap(dynamic data) {
    if (data == null) return {};
    final map = data as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, (value as int?) ?? 0));
  }

  String _weekdayName(int day) {
    switch (day) {
      case 1:
        return 'Montag';
      case 2:
        return 'Dienstag';
      case 3:
        return 'Mittwoch';
      case 4:
        return 'Donnerstag';
      case 5:
        return 'Freitag';
      case 6:
        return 'Samstag';
      case 7:
        return 'Sonntag';
      default:
        return 'Unbekannt';
    }
  }
}
