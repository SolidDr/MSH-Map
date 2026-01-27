import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';

/// Interaktives Sterne-Rating Widget
class RatingInputWidget extends StatefulWidget {
  const RatingInputWidget({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.size = 40,
    this.spacing = 8,
    this.enabled = true,
  });

  final int initialRating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final double spacing;
  final bool enabled;

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  late int _currentRating;
  int? _hoverRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(RatingInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _currentRating = widget.initialRating;
    }
  }

  void _onStarTap(int rating) {
    if (!widget.enabled) return;
    setState(() {
      _currentRating = rating;
    });
    widget.onRatingChanged?.call(rating);
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = _hoverRating ?? _currentRating;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isFilled = starNumber <= displayRating;

        return Padding(
          padding: EdgeInsets.only(
            right: index < 4 ? widget.spacing : 0,
          ),
          child: MouseRegion(
            onEnter: widget.enabled
                ? (_) => setState(() => _hoverRating = starNumber)
                : null,
            onExit: widget.enabled
                ? (_) => setState(() => _hoverRating = null)
                : null,
            child: GestureDetector(
              onTap: () => _onStarTap(starNumber),
              child: AnimatedScale(
                scale: _hoverRating == starNumber ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: widget.size,
                  color: widget.enabled
                      ? (isFilled ? MshColors.starFilled : MshColors.starEmpty)
                      : MshColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Kompakte Sterne-Anzeige (nicht interaktiv)
class RatingDisplayWidget extends StatelessWidget {
  const RatingDisplayWidget({
    super.key,
    required this.rating,
    this.totalCount,
    this.size = 18,
    this.showCount = true,
  });

  final double rating;
  final int? totalCount;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sterne
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          final isFull = starNumber <= rating.floor();
          final isHalf =
              !isFull && starNumber == rating.ceil() && rating % 1 >= 0.3;

          return Icon(
            isFull
                ? Icons.star_rounded
                : isHalf
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: isFull || isHalf
                ? MshColors.starFilled
                : MshColors.starEmpty,
          );
        }),

        // Durchschnitt und Anzahl
        if (showCount && totalCount != null) ...[
          const SizedBox(width: MshSpacing.xs),
          Text(
            '${rating.toStringAsFixed(1)} ($totalCount)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: MshColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Vertikale Verteilung der Sterne (für Detail-Ansicht)
class RatingDistributionWidget extends StatelessWidget {
  const RatingDistributionWidget({
    super.key,
    required this.distribution,
    required this.totalCount,
  });

  final Map<int, int> distribution;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index; // 5, 4, 3, 2, 1
        final count = distribution[stars] ?? 0;
        final percentage = totalCount > 0 ? count / totalCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: MshSpacing.xs),
          child: Row(
            children: [
              // Sterne-Zahl
              SizedBox(
                width: 16,
                child: Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MshColors.textSecondary,
                  ),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: MshColors.starFilled,
              ),
              const SizedBox(width: MshSpacing.xs),

              // Progress Bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: MshColors.starEmpty.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      MshColors.starFilled,
                    ),
                  ),
                ),
              ),

              // Anzahl
              const SizedBox(width: MshSpacing.sm),
              SizedBox(
                width: 28,
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MshColors.textMuted,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
