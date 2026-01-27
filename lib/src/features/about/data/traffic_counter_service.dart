import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service für anonymisierten Traffic-Counter
///
/// Datenschutzkonform: Keine Cookies, keine User-IDs, nur aggregierte Zähler.
/// SharedPreferences wird nur lokal genutzt, um Mehrfachzählung am gleichen Tag zu vermeiden.
class TrafficCounterService {
  TrafficCounterService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionPath = 'stats';
  static const String _documentId = 'traffic_counter';
  static const String _lastCountedKey = 'traffic_last_counted';

  final FirebaseFirestore _firestore;

  /// Inkrementiert den Counter einmalig pro Tag
  Future<void> incrementIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      final lastCounted = prefs.getString(_lastCountedKey);

      // Nur einmal pro Tag zählen
      if (lastCounted == today) return;

      final docRef = _firestore.collection(_collectionPath).doc(_documentId);
      final weekKey = _getWeekKey();
      final monthKey = _getMonthKey();

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          // Dokument initialisieren
          transaction.set(docRef, {
            'total': 1,
            'daily': {today: 1},
            'weekly': {weekKey: 1},
            'monthly': {monthKey: 1},
          });
        } else {
          // Counter inkrementieren
          final data = doc.data()!;
          final dailyData = data['daily'] as Map<String, dynamic>? ?? {};
          final weeklyData = data['weekly'] as Map<String, dynamic>? ?? {};
          final monthlyData = data['monthly'] as Map<String, dynamic>? ?? {};

          final daily = Map<String, dynamic>.from(dailyData);
          final weekly = Map<String, dynamic>.from(weeklyData);
          final monthly = Map<String, dynamic>.from(monthlyData);

          daily[today] = ((daily[today] as int?) ?? 0) + 1;
          weekly[weekKey] = ((weekly[weekKey] as int?) ?? 0) + 1;
          monthly[monthKey] = ((monthly[monthKey] as int?) ?? 0) + 1;

          transaction.update(docRef, {
            'total': FieldValue.increment(1),
            'daily': daily,
            'weekly': weekly,
            'monthly': monthly,
          });
        }
      });

      // Merken, dass heute gezählt wurde
      await prefs.setString(_lastCountedKey, today);
    } catch (e) {
      // Fehler beim Zählen ignorieren - keine App-Auswirkung
      // ignore: avoid_print
      print('Traffic counter error: $e');
    }
  }

  /// Holt die aktuellen Counter-Werte
  Future<TrafficStats> getStats() async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_documentId)
          .get();

      if (!doc.exists) {
        return const TrafficStats(total: 0, monthly: 0, weekly: 0, daily: 0);
      }

      final data = doc.data()!;
      final today = _getTodayKey();
      final weekKey = _getWeekKey();
      final monthKey = _getMonthKey();

      final daily = data['daily'] as Map<String, dynamic>? ?? {};
      final weekly = data['weekly'] as Map<String, dynamic>? ?? {};
      final monthly = data['monthly'] as Map<String, dynamic>? ?? {};

      return TrafficStats(
        total: (data['total'] as int?) ?? 0,
        monthly: (monthly[monthKey] as int?) ?? 0,
        weekly: (weekly[weekKey] as int?) ?? 0,
        daily: (daily[today] as int?) ?? 0,
      );
    } on Exception {
      return const TrafficStats(total: 0, monthly: 0, weekly: 0, daily: 0);
    }
  }

  /// Stream für Echtzeit-Updates
  Stream<TrafficStats> watchStats() {
    return _firestore
        .collection(_collectionPath)
        .doc(_documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return const TrafficStats(total: 0, monthly: 0, weekly: 0, daily: 0);
      }

      final data = doc.data()!;
      final today = _getTodayKey();
      final weekKey = _getWeekKey();
      final monthKey = _getMonthKey();

      final daily = data['daily'] as Map<String, dynamic>? ?? {};
      final weekly = data['weekly'] as Map<String, dynamic>? ?? {};
      final monthly = data['monthly'] as Map<String, dynamic>? ?? {};

      return TrafficStats(
        total: (data['total'] as int?) ?? 0,
        monthly: (monthly[monthKey] as int?) ?? 0,
        weekly: (weekly[weekKey] as int?) ?? 0,
        daily: (daily[today] as int?) ?? 0,
      );
    });
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getWeekKey() {
    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    return '${now.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  String _getMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  int _getWeekNumber(DateTime date) {
    // ISO 8601 Wochennummer
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekday = date.weekday;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}

/// Traffic-Statistiken
class TrafficStats {
  const TrafficStats({
    required this.total,
    required this.monthly,
    required this.weekly,
    required this.daily,
  });

  final int total;
  final int monthly;
  final int weekly;
  final int daily;
}
