import 'package:flutter/material.dart';

import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';

/// Einzelne Bewertung
class Review {
  const Review({
    required this.rating,
    this.text,
    this.date,
    this.source,
    this.authorName,
  });

  final double rating; // 1-5
  final String? text;
  final DateTime? date;
  final String? source; // z.B. "Google", "Tripadvisor"
  final String? authorName;
}

/// Bewertungs-Sektion für Ort-Details
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.reviews,
    this.averageRating,
  });

  final List<Review> reviews;
  final double? averageRating;

  @override
  Widget build(BuildContext context) {
    // Berechne Durchschnitt falls nicht gegeben
    final avg = averageRating ??
        (reviews.isNotEmpty
            ? reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length
            : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titel
        Row(
          children: [
            Text(
              'Bewertungen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (reviews.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: MshColors.textMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${reviews.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: MshColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: MshSpacing.md),

        // Keine Bewertungen
        if (reviews.isEmpty)
          _NoReviews()
        else ...[
          // Zusammenfassung
          _ReviewsSummary(
            averageRating: avg,
            reviewCount: reviews.length,
          ),
          const SizedBox(height: MshSpacing.md),

          // Einzelne Bewertungen (max 5)
          ...reviews.take(5).map((review) => Padding(
                padding: const EdgeInsets.only(bottom: MshSpacing.sm),
                child: _ReviewItem(review: review),
              )),

          // "Mehr anzeigen" Button
          if (reviews.length > 5)
            TextButton(
              onPressed: () {
                // TODO: Alle Bewertungen anzeigen
              },
              child: Text(
                'Alle ${reviews.length} Bewertungen anzeigen',
                style: TextStyle(color: MshColors.primary),
              ),
            ),
        ],
      ],
    );
  }
}

/// Keine Bewertungen vorhanden
class _NoReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.lg),
      decoration: BoxDecoration(
        color: MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 40,
            color: MshColors.textMuted,
          ),
          const SizedBox(height: MshSpacing.sm),
          Text(
            'Noch keine Bewertungen',
            style: TextStyle(
              color: MshColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sei der Erste, der diesen Ort bewertet!',
            style: TextStyle(
              color: MshColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Zusammenfassung der Bewertungen
class _ReviewsSummary extends StatelessWidget {
  const _ReviewsSummary({
    required this.averageRating,
    required this.reviewCount,
  });

  final double averageRating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Durchschnittliche Bewertung
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MshColors.primary,
                    ),
              ),
              _StarRating(rating: averageRating),
            ],
          ),
          const SizedBox(width: MshSpacing.lg),

          // Anzahl Bewertungen
          Expanded(
            child: Text(
              'basierend auf $reviewCount ${reviewCount == 1 ? 'Bewertung' : 'Bewertungen'}',
              style: TextStyle(
                color: MshColors.textSecondary,
                fontSize: 13,
              ),
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

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: MshColors.primary,
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
              _StarRating(rating: review.rating, size: 16),
              if (review.date != null)
                Text(
                  _formatDate(review.date!),
                  style: TextStyle(
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
              style: TextStyle(
                color: MshColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],

          // Quelle
          if (review.source != null) ...[
            const SizedBox(height: MshSpacing.sm),
            Text(
              'Quelle: ${review.source}',
              style: TextStyle(
                color: MshColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

/// Sterne-Anzeige
class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.rating,
    this.size = 18,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;

        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(
          icon,
          size: size,
          color: MshColors.primary,
        );
      }),
    );
  }
}
