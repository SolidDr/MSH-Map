import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';
import '../../features/ratings/application/rating_providers.dart';
import '../../features/ratings/domain/rating_model.dart';
import '../../features/ratings/presentation/rating_bottom_sheet.dart';
import '../../features/ratings/presentation/rating_input_widget.dart';

/// Bewertungs-Sektion für POI-Details
///
/// Zeigt Bewertungen aus Firestore und ermöglicht anonymes Bewerten
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    required this.poiId,
    required this.poiName,
    super.key,
  });

  final String poiId;
  final String poiName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(poiRatingProvider(poiId));
    final hasRatedAsync = ref.watch(hasRatedProvider(poiId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titel mit Bewerten-Button
        Row(
          children: [
            Text(
              'Bewertungen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            // Bewerten-Button
            hasRatedAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => _buildRateButton(context, false),
              data: (hasRated) => _buildRateButton(context, hasRated),
            ),
          ],
        ),
        const SizedBox(height: MshSpacing.md),

        // Bewertungs-Inhalt
        ratingAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(MshSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _NoReviews(
            poiId: poiId,
            poiName: poiName,
          ),
          data: (rating) {
            if (!rating.hasRatings) {
              return _NoReviews(
                poiId: poiId,
                poiName: poiName,
              );
            }
            return _ReviewsContent(
              rating: rating,
              poiId: poiId,
              poiName: poiName,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRateButton(BuildContext context, bool hasRated) {
    return TextButton.icon(
      onPressed: () => RatingBottomSheet.show(
        context: context,
        poiId: poiId,
        poiName: poiName,
      ),
      icon: Icon(
        hasRated ? Icons.check_circle : Icons.star_outline_rounded,
        size: 18,
        color: hasRated ? MshColors.success : MshColors.primary,
      ),
      label: Text(
        hasRated ? 'Bewertet' : 'Bewerten',
        style: TextStyle(
          color: hasRated ? MshColors.success : MshColors.primary,
        ),
      ),
    );
  }
}

/// Keine Bewertungen vorhanden
class _NoReviews extends StatelessWidget {
  const _NoReviews({
    required this.poiId,
    required this.poiName,
  });

  final String poiId;
  final String poiName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.lg),
      decoration: BoxDecoration(
        color: MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 40,
            color: MshColors.textMuted,
          ),
          const SizedBox(height: MshSpacing.sm),
          const Text(
            'Noch keine Bewertungen',
            style: TextStyle(
              color: MshColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sei der Erste, der diesen Ort bewertet!',
            style: TextStyle(
              color: MshColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: MshSpacing.md),
          FilledButton.icon(
            onPressed: () => RatingBottomSheet.show(
              context: context,
              poiId: poiId,
              poiName: poiName,
            ),
            icon: const Icon(Icons.star_rounded, size: 18),
            label: const Text('Jetzt bewerten'),
          ),
        ],
      ),
    );
  }
}

/// Bewertungen mit Inhalt
class _ReviewsContent extends StatelessWidget {
  const _ReviewsContent({
    required this.rating,
    required this.poiId,
    required this.poiName,
  });

  final PoiRating rating;
  final String poiId;
  final String poiName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zusammenfassung
        _ReviewsSummary(rating: rating),
        const SizedBox(height: MshSpacing.md),

        // Einzelne Bewertungen (max 5)
        if (rating.reviews.isNotEmpty) ...[
          ...rating.reviews.take(5).map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: MshSpacing.sm),
                  child: _ReviewItem(review: review),
                ),
              ),

          // "Mehr anzeigen" wenn mehr als 5
          if (rating.reviews.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Alle Bewertungen in Modal anzeigen
                },
                child: Text(
                  'Alle ${rating.totalCount} Bewertungen anzeigen',
                  style: const TextStyle(color: MshColors.primary),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Zusammenfassung der Bewertungen
class _ReviewsSummary extends StatelessWidget {
  const _ReviewsSummary({required this.rating});

  final PoiRating rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      ),
      child: Row(
        children: [
          // Durchschnittliche Bewertung
          Column(
            children: [
              Text(
                rating.formattedRating,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MshColors.textStrong,
                    ),
              ),
              RatingDisplayWidget(
                rating: rating.averageRating,
                showCount: false,
                size: 16,
              ),
            ],
          ),
          const SizedBox(width: MshSpacing.lg),

          // Verteilung
          Expanded(
            child: RatingDistributionWidget(
              distribution: rating.distribution,
              totalCount: rating.totalCount,
            ),
          ),
        ],
      ),
    );
  }
}

/// Einzelne Bewertung
class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final ReviewEntry review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        border: const Border(
          left: BorderSide(
            color: MshColors.starFilled,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sterne + Datum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingDisplayWidget(
                rating: review.rating.toDouble(),
                showCount: false,
                size: 16,
              ),
              Text(
                review.relativeTime,
                style: const TextStyle(
                  color: MshColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          // Text
          if (review.text != null && review.text!.isNotEmpty) ...[
            const SizedBox(height: MshSpacing.sm),
            Text(
              review.text!,
              style: const TextStyle(
                color: MshColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
