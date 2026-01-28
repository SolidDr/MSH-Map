import 'dart:async' show unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../../analytics/data/usage_analytics_service.dart';
import '../domain/rating_model.dart';

/// Service für anonymes Bewertungssystem
///
/// GDPR-konform: Keine User-IDs, keine Cookies, nur aggregierte Daten.
/// SharedPreferences wird nur lokal genutzt, um Mehrfachbewertungen zu vermeiden.
class RatingService {
  RatingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionPath = 'ratings';
  static const String _ratedPoisKey = 'rated_pois';
  static const int _maxReviewsToKeep = 10;

  final FirebaseFirestore _firestore;

  /// Bewertung abgeben (anonym)
  ///
  /// Returns true wenn erfolgreich, false wenn bereits bewertet oder Fehler
  Future<bool> submitRating({
    required String poiId,
    required int rating,
    String? comment,
  }) async {
    // Validierung
    if (rating < 1 || rating > 5) return false;

    try {
      // Prüfen ob bereits bewertet
      if (await hasRated(poiId)) {
        debugPrint('POI $poiId wurde bereits bewertet');
        return false;
      }

      final docRef = _firestore.collection(_collectionPath).doc(poiId);
      final now = DateTime.now();

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          // Erstes Rating für diesen POI
          transaction.set(docRef, {
            'averageRating': rating.toDouble(),
            'totalCount': 1,
            'distribution': {
              '1': rating == 1 ? 1 : 0,
              '2': rating == 2 ? 1 : 0,
              '3': rating == 3 ? 1 : 0,
              '4': rating == 4 ? 1 : 0,
              '5': rating == 5 ? 1 : 0,
            },
            'reviews': [
              {
                'rating': rating,
                if (comment != null && comment.isNotEmpty) 'text': comment,
                'date': now.toIso8601String(),
              },
            ],
            'lastUpdated': now.toIso8601String(),
          });
        } else {
          // Bestehendes Rating aktualisieren
          final data = doc.data()!;
          final oldAverage = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
          final oldCount = (data['totalCount'] as int?) ?? 0;
          final distribution =
              Map<String, dynamic>.from(data['distribution'] as Map? ?? {});
          final reviews = List<Map<String, dynamic>>.from(
            (data['reviews'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          );

          // Neuen Durchschnitt berechnen
          final newCount = oldCount + 1;
          final newAverage =
              ((oldAverage * oldCount) + rating) / newCount;

          // Distribution aktualisieren
          final ratingKey = rating.toString();
          distribution[ratingKey] =
              ((distribution[ratingKey] as int?) ?? 0) + 1;

          // Neues Review hinzufügen (am Anfang)
          reviews.insert(0, {
            'rating': rating,
            if (comment != null && comment.isNotEmpty) 'text': comment,
            'date': now.toIso8601String(),
          });

          // Nur die letzten X Reviews behalten
          final trimmedReviews = reviews.take(_maxReviewsToKeep).toList();

          transaction.update(docRef, {
            'averageRating': newAverage,
            'totalCount': newCount,
            'distribution': distribution,
            'reviews': trimmedReviews,
            'lastUpdated': now.toIso8601String(),
          });
        }
      });

      // Lokal merken, dass bewertet wurde
      await _markAsRated(poiId);

      // Track rating for analytics (fire and forget)
      unawaited(UsageAnalyticsService().trackRatingSubmitted());

      return true;
    } catch (e) {
      debugPrint('Fehler beim Bewerten: $e');
      return false;
    }
  }

  /// Prüft ob dieser POI bereits bewertet wurde (auf diesem Gerät)
  Future<bool> hasRated(String poiId) async {
    final prefs = await SharedPreferences.getInstance();
    final ratedPois = prefs.getStringList(_ratedPoisKey) ?? [];
    return ratedPois.contains(poiId);
  }

  /// Markiert einen POI als bewertet (lokal)
  Future<void> _markAsRated(String poiId) async {
    final prefs = await SharedPreferences.getInstance();
    final ratedPois = prefs.getStringList(_ratedPoisKey) ?? [];
    if (!ratedPois.contains(poiId)) {
      ratedPois.add(poiId);
      await prefs.setStringList(_ratedPoisKey, ratedPois);
    }
  }

  /// Bewertungen für einen POI laden
  Future<PoiRating> getRating(String poiId) async {
    try {
      final doc =
          await _firestore.collection(_collectionPath).doc(poiId).get();

      if (!doc.exists) {
        return PoiRating.empty(poiId);
      }

      return PoiRating.fromFirestore(poiId, doc.data()!);
    } catch (e) {
      debugPrint('Fehler beim Laden der Bewertungen: $e');
      return PoiRating.empty(poiId);
    }
  }

  /// Stream für Echtzeit-Updates der Bewertungen
  Stream<PoiRating> watchRating(String poiId) {
    return _firestore
        .collection(_collectionPath)
        .doc(poiId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return PoiRating.empty(poiId);
      }
      return PoiRating.fromFirestore(poiId, doc.data()!);
    });
  }

  /// Alle Bewertungen laden (für Admin-Dashboard)
  Future<List<PoiRating>> getAllRatings() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('totalCount', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => PoiRating.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Fehler beim Laden aller Bewertungen: $e');
      return [];
    }
  }

  /// Neueste Bewertungen laden (für Admin-Dashboard)
  Future<List<({String poiId, ReviewEntry review})>> getRecentReviews({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('lastUpdated', descending: true)
          .limit(limit)
          .get();

      final recentReviews = <({String poiId, ReviewEntry review})>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reviews = (data['reviews'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

        for (final reviewData in reviews.take(3)) {
          recentReviews.add((
            poiId: doc.id,
            review: ReviewEntry.fromMap(reviewData),
          ));
        }
      }

      // Nach Datum sortieren und limitieren
      recentReviews.sort((a, b) => b.review.date.compareTo(a.review.date));
      return recentReviews.take(limit).toList();
    } catch (e) {
      debugPrint('Fehler beim Laden der neuesten Bewertungen: $e');
      return [];
    }
  }
}
