/// Parser für OSM-Öffnungszeiten im String-Format
/// Beispiel: "Mo 08:00-12:00,14:30-17:30; Tu,We,Fr 08:00-12:00; Sa 09:00-13:00"
class OpeningHoursParser {
  /// Prüft ob aktuell geöffnet basierend auf OSM-String
  static bool isOpenNow(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) return false;

    final now = DateTime.now();
    final currentDay = _getDayAbbr(now.weekday);
    final currentMinutes = now.hour * 60 + now.minute;

    // Parse den String
    final dayRanges = _parseOpeningHours(openingHours);

    // Finde Zeiten für heute
    final todayRanges = dayRanges[currentDay];
    if (todayRanges == null || todayRanges.isEmpty) return false;

    // Prüfe ob aktuelle Zeit in einem der Zeitfenster liegt
    for (final range in todayRanges) {
      if (currentMinutes >= range.start && currentMinutes <= range.end) {
        return true;
      }
    }

    return false;
  }

  /// Gibt Öffnungszeiten für heute zurück (für Tooltip)
  static String? getTodayHours(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) return null;

    final now = DateTime.now();
    final currentDay = _getDayAbbr(now.weekday);

    final dayRanges = _parseOpeningHours(openingHours);
    final todayRanges = dayRanges[currentDay];

    if (todayRanges == null || todayRanges.isEmpty) return 'Heute geschlossen';

    final timeStrings = todayRanges.map((r) => '${_formatTime(r.start)} - ${_formatTime(r.end)}');
    return timeStrings.join(', ');
  }

  /// Gibt Minuten bis zur Schließung zurück
  /// Returns: positive Zahl wenn offen, null wenn geschlossen oder unbekannt
  static int? getMinutesUntilClose(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) return null;

    final now = DateTime.now();
    final currentDay = _getDayAbbr(now.weekday);
    final currentMinutes = now.hour * 60 + now.minute;

    final dayRanges = _parseOpeningHours(openingHours);
    final todayRanges = dayRanges[currentDay];

    if (todayRanges == null || todayRanges.isEmpty) return null;

    // Finde das aktuelle Zeitfenster
    for (final range in todayRanges) {
      if (currentMinutes >= range.start && currentMinutes <= range.end) {
        return range.end - currentMinutes;
      }
    }

    return null; // Nicht in einem Zeitfenster = geschlossen
  }

  /// Berechnet Marker-Opacity basierend auf Öffnungsstatus
  /// - Geschlossen → 0.35
  /// - < 30 min bis Schließung → 0.5
  /// - < 1h bis Schließung → 0.65
  /// - < 2h bis Schließung → 0.8
  /// - > 2h → 1.0
  /// - Unbekannt (keine Öffnungszeiten) → 0.5
  static double getMarkerOpacity(String? openingHours) {
    // Keine Öffnungszeiten bekannt → 50% Opacity
    if (openingHours == null || openingHours.isEmpty) return 0.5;

    final minutesUntilClose = getMinutesUntilClose(openingHours);

    // Geschlossen
    if (minutesUntilClose == null) return 0.35;

    // Offen - Opacity basierend auf verbleibender Zeit
    if (minutesUntilClose < 30) return 0.5;
    if (minutesUntilClose < 60) return 0.65;
    if (minutesUntilClose < 120) return 0.8;

    return 1.0;
  }

  /// Parst OSM-Öffnungszeiten-String zu Map<Tag, List<Zeitfenster>>
  static Map<String, List<_TimeRange>> _parseOpeningHours(String hours) {
    final result = <String, List<_TimeRange>>{};

    // Normalisiere String
    final normalizedHours = hours.trim();

    // Teile nach Semikolon (verschiedene Tage/Gruppen)
    final segments = normalizedHours.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty);

    for (final segment in segments) {
      _parseSegment(segment, result);
    }

    return result;
  }

  /// Parst ein Segment wie "Mo,Tu,We 08:00-12:00,14:00-17:00"
  static void _parseSegment(String segment, Map<String, List<_TimeRange>> result) {
    // Finde Tages-Präfix und Zeiten
    // Format kann sein: "Mo 08:00-12:00" oder "Mo,Tu,We 08:00-12:00" oder "Mo-Fr 08:00-12:00"

    // Regex um Tage und Zeiten zu trennen
    final match = RegExp(r'^([A-Za-z,\-]+)\s+(.+)$').firstMatch(segment);
    if (match == null) return;

    final daysPart = match.group(1)!;
    final timesPart = match.group(2)!;

    // Parse Tage
    final days = _parseDays(daysPart);

    // Parse Zeiten
    final times = _parseTimes(timesPart);

    // Füge zu Ergebnis hinzu
    for (final day in days) {
      result.putIfAbsent(day, () => []);
      result[day]!.addAll(times);
    }
  }

  /// Parst Tagesangabe wie "Mo", "Mo,Tu,We", "Mo-Fr"
  static List<String> _parseDays(String daysPart) {
    final result = <String>[];

    // Prüfe auf Bereich (Mo-Fr)
    if (daysPart.contains('-')) {
      final parts = daysPart.split('-');
      if (parts.length == 2) {
        final startDay = _normalizeDayAbbr(parts[0].trim());
        final endDay = _normalizeDayAbbr(parts[1].trim());
        result.addAll(_getDayRange(startDay, endDay));
      }
    }
    // Prüfe auf Komma-Liste (Mo,Tu,We)
    else if (daysPart.contains(',')) {
      final parts = daysPart.split(',');
      for (final part in parts) {
        final day = _normalizeDayAbbr(part.trim());
        if (day.isNotEmpty) result.add(day);
      }
    }
    // Einzelner Tag
    else {
      final day = _normalizeDayAbbr(daysPart.trim());
      if (day.isNotEmpty) result.add(day);
    }

    return result;
  }

  /// Parst Zeitangaben wie "08:00-12:00" oder "08:00-12:00,14:00-17:00"
  static List<_TimeRange> _parseTimes(String timesPart) {
    final result = <_TimeRange>[];

    final ranges = timesPart.split(',').map((s) => s.trim());

    for (final range in ranges) {
      final parts = range.split('-');
      if (parts.length == 2) {
        final start = _parseTime(parts[0].trim());
        final end = _parseTime(parts[1].trim());
        if (start != null && end != null) {
          result.add(_TimeRange(start, end));
        }
      }
    }

    return result;
  }

  /// Parst Zeit wie "08:00" zu Minuten seit Mitternacht
  static int? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  /// Formatiert Minuten zu "HH:MM"
  static String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Gibt alle Tage zwischen start und end zurück
  static List<String> _getDayRange(String start, String end) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final startIdx = days.indexOf(start);
    final endIdx = days.indexOf(end);

    if (startIdx == -1 || endIdx == -1) return [];

    final result = <String>[];
    for (var i = startIdx; i <= endIdx; i++) {
      result.add(days[i]);
    }
    return result;
  }

  /// Normalisiert Tagesabkürzung zu zweistelligem Format
  static String _normalizeDayAbbr(String day) {
    final lower = day.toLowerCase();

    // Deutsche Abkürzungen
    if (lower.startsWith('mo')) return 'Mo';
    if (lower.startsWith('di') || lower.startsWith('tu')) return 'Tu';
    if (lower.startsWith('mi') || lower.startsWith('we')) return 'We';
    if (lower.startsWith('do') || lower.startsWith('th')) return 'Th';
    if (lower.startsWith('fr')) return 'Fr';
    if (lower.startsWith('sa')) return 'Sa';
    if (lower.startsWith('so') || lower.startsWith('su')) return 'Su';

    return '';
  }

  /// Gibt Tagesabkürzung für DateTime.weekday zurück
  static String _getDayAbbr(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }
}

/// Zeitfenster mit Start und Ende in Minuten seit Mitternacht
class _TimeRange {
  const _TimeRange(this.start, this.end);
  final int start;
  final int end;
}
