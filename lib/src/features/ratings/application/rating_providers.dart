import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rating_service.dart';
import '../domain/rating_model.dart';

/// Provider für den Rating Service
final ratingServiceProvider = Provider<RatingService>((ref) {
  return RatingService();
});

/// Provider für Bewertungen eines POIs (Stream für Echtzeit-Updates)
final poiRatingProvider =
    StreamProvider.family<PoiRating, String>((ref, poiId) {
  final service = ref.watch(ratingServiceProvider);
  return service.watchRating(poiId);
});

/// Provider um zu prüfen ob ein POI bereits bewertet wurde
final hasRatedProvider =
    FutureProvider.family<bool, String>((ref, poiId) async {
  final service = ref.watch(ratingServiceProvider);
  return service.hasRated(poiId);
});

/// Provider für alle Bewertungen (Admin-Dashboard)
final allRatingsProvider = FutureProvider<List<PoiRating>>((ref) async {
  final service = ref.watch(ratingServiceProvider);
  return service.getAllRatings();
});

/// Provider für neueste Bewertungen (Admin-Dashboard)
final recentReviewsProvider =
    FutureProvider<List<({String poiId, ReviewEntry review})>>((ref) async {
  final service = ref.watch(ratingServiceProvider);
  return service.getRecentReviews();
});

/// Notifier für das Absenden einer Bewertung (Riverpod 3.x)
class RatingSubmitNotifier extends Notifier<AsyncValue<bool?>> {
  late final RatingService _service;

  @override
  AsyncValue<bool?> build() {
    _service = ref.watch(ratingServiceProvider);
    return const AsyncValue.data(null);
  }

  Future<bool> submit({
    required String poiId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();

    try {
      final success = await _service.submitRating(
        poiId: poiId,
        rating: rating,
        comment: comment,
      );
      state = AsyncValue.data(success);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider für das Absenden einer Bewertung (Riverpod 3.x)
final ratingSubmitProvider =
    NotifierProvider<RatingSubmitNotifier, AsyncValue<bool?>>(
  RatingSubmitNotifier.new,
);
