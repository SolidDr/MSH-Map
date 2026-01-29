import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../shared/widgets/msh_bottom_sheet.dart';
import '../application/rating_providers.dart';
import '../domain/rating_model.dart';
import 'rating_input_widget.dart';

/// Bottom Sheet für POI-Bewertung
class RatingBottomSheet extends ConsumerStatefulWidget {
  const RatingBottomSheet({
    required this.poiId,
    required this.poiName,
    super.key,
  });

  final String poiId;
  final String poiName;

  /// Zeigt das Rating Bottom Sheet
  static Future<bool?> show({
    required BuildContext context,
    required String poiId,
    required String poiName,
  }) {
    return MshBottomSheet.show<bool>(
      context: context,
      title: 'Bewerten',
      subtitle: poiName,
      icon: Icons.star_rounded,
      iconColor: MshColors.starFilled,
      size: MshBottomSheetSize.medium,
      builder: (_) => RatingBottomSheet(
        poiId: poiId,
        poiName: poiName,
      ),
    );
  }

  @override
  ConsumerState<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<RatingBottomSheet> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(ratingSubmitProvider.notifier).submit(
          poiId: widget.poiId,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        // Invalidate providers to refresh data
        ref.invalidate(poiRatingProvider(widget.poiId));
        ref.invalidate(hasRatedProvider(widget.poiId));

        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Danke für deine Bewertung!'),
            backgroundColor: MshColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bewertung konnte nicht gespeichert werden'),
            backgroundColor: MshColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRatedAsync = ref.watch(hasRatedProvider(widget.poiId));
    final ratingAsync = ref.watch(poiRatingProvider(widget.poiId));

    return hasRatedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildRatingForm(context, null),
      data: (hasRated) {
        if (hasRated) {
          return _buildAlreadyRated(context, ratingAsync.value);
        }
        return _buildRatingForm(context, ratingAsync.value);
      },
    );
  }

  Widget _buildAlreadyRated(BuildContext context, PoiRating? rating) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 64,
          color: MshColors.success,
        ),
        const SizedBox(height: MshSpacing.md),
        Text(
          'Du hast bereits bewertet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.sm),
        Text(
          'Danke für dein Feedback!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MshColors.textSecondary,
              ),
        ),
        if (rating != null && rating.hasRatings) ...[
          const SizedBox(height: MshSpacing.lg),
          _buildCurrentRating(context, rating),
        ],
        const SizedBox(height: MshSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingForm(BuildContext context, PoiRating? currentRating) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Aktuelle Bewertung anzeigen (wenn vorhanden)
        if (currentRating != null && currentRating.hasRatings) ...[
          _buildCurrentRating(context, currentRating),
          const SizedBox(height: MshSpacing.lg),
          const Divider(),
          const SizedBox(height: MshSpacing.lg),
        ],

        // Deine Bewertung
        Text(
          'Deine Bewertung',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.md),

        // Sterne-Input
        Center(
          child: RatingInputWidget(
            initialRating: _selectedRating,
            onRatingChanged: (rating) {
              setState(() => _selectedRating = rating);
            },
            size: 48,
            spacing: 12,
          ),
        ),

        // Rating-Text (optional)
        if (_selectedRating > 0) ...[
          const SizedBox(height: MshSpacing.sm),
          Center(
            child: Text(
              _getRatingText(_selectedRating),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MshColors.textSecondary,
                  ),
            ),
          ),
        ],

        const SizedBox(height: MshSpacing.lg),

        // Kommentar-Feld
        TextField(
          controller: _commentController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Kommentar (optional)',
            hintStyle: const TextStyle(color: MshColors.textMuted),
            filled: true,
            fillColor: MshColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(MshSpacing.md),
          ),
        ),

        const SizedBox(height: MshSpacing.lg),

        // Submit Button
        FilledButton.icon(
          onPressed: _selectedRating > 0 && !_isSubmitting
              ? _submitRating
              : null,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: Text(_isSubmitting ? 'Wird gesendet...' : 'Bewertung abgeben'),
        ),

        const SizedBox(height: MshSpacing.sm),

        // Datenschutz-Hinweis
        Text(
          'Anonym - Keine persönlichen Daten werden gespeichert',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MshColors.textMuted,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrentRating(BuildContext context, PoiRating rating) {
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
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MshColors.textStrong,
                    ),
              ),
              RatingDisplayWidget(
                rating: rating.averageRating,
                showCount: false,
                size: 16,
              ),
              const SizedBox(height: MshSpacing.xs),
              Text(
                '${rating.totalCount} ${rating.totalCount == 1 ? 'Bewertung' : 'Bewertungen'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
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

  String _getRatingText(int rating) {
    return switch (rating) {
      1 => 'Schlecht',
      2 => 'Nicht gut',
      3 => 'In Ordnung',
      4 => 'Gut',
      5 => 'Ausgezeichnet',
      _ => '',
    };
  }
}
