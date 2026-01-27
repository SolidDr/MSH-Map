// Domain Models für anonymes Bewertungssystem
// GDPR-konform: Keine User-IDs, keine Cookies, nur aggregierte Daten

/// Aggregierte Bewertungen für einen POI
class PoiRating {
  const PoiRating({
    required this.poiId,
    required this.averageRating,
    required this.totalCount,
    required this.distribution,
    required this.reviews,
    this.lastUpdated,
  });

  /// Erstellt aus Firestore-Daten
  factory PoiRating.fromFirestore(String poiId, Map<String, dynamic> data) {
    final reviewsData = data['reviews'] as List<dynamic>? ?? [];
    final distributionData =
        data['distribution'] as Map<String, dynamic>? ?? {};

    return PoiRating(
      poiId: poiId,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalCount: (data['totalCount'] as int?) ?? 0,
      distribution: {
        1: (distributionData['1'] as int?) ?? 0,
        2: (distributionData['2'] as int?) ?? 0,
        3: (distributionData['3'] as int?) ?? 0,
        4: (distributionData['4'] as int?) ?? 0,
        5: (distributionData['5'] as int?) ?? 0,
      },
      reviews: reviewsData
          .map((e) => ReviewEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.tryParse(data['lastUpdated'] as String)
          : null,
    );
  }

  /// Leeres Rating (wenn noch keine Bewertungen)
  factory PoiRating.empty(String poiId) {
    return PoiRating(
      poiId: poiId,
      averageRating: 0,
      totalCount: 0,
      distribution: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      reviews: const <ReviewEntry>[],
    );
  }

  final String poiId;
  final double averageRating;
  final int totalCount;

  /// Verteilung der Sterne: {1: count, 2: count, 3: count, 4: count, 5: count}
  final Map<int, int> distribution;

  /// Letzte Bewertungen (max 10 für Anzeige)
  final List<ReviewEntry> reviews;

  final DateTime? lastUpdated;

  /// Prüft ob Bewertungen vorhanden sind
  bool get hasRatings => totalCount > 0;

  /// Gibt formatierte Durchschnittsbewertung zurück (z.B. "4.2")
  String get formattedRating => averageRating.toStringAsFixed(1);
}

/// Einzelne Bewertung (ohne Personenbezug)
class ReviewEntry {
  const ReviewEntry({
    required this.rating,
    required this.date,
    this.text,
  });

  factory ReviewEntry.fromMap(Map<String, dynamic> map) {
    return ReviewEntry(
      rating: (map['rating'] as int?) ?? 0,
      text: map['text'] as String?,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Sterne-Bewertung (1-5)
  final int rating;

  /// Optionaler Kommentar
  final String? text;

  /// Zeitpunkt der Bewertung
  final DateTime date;

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      if (text != null && text!.isNotEmpty) 'text': text,
      'date': date.toIso8601String(),
    };
  }

  /// Formatiertes Datum (z.B. "15.01.2026")
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Relative Zeit (z.B. "vor 2 Stunden")
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'gerade eben';
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
    if (diff.inDays < 7) return 'vor ${diff.inDays} Tagen';
    if (diff.inDays < 30) return 'vor ${(diff.inDays / 7).floor()} Wochen';

    return formattedDate;
  }
}
