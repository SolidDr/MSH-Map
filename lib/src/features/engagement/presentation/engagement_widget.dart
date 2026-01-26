import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/config/feature_flags.dart';
import '../application/engagement_provider.dart';
import '../data/engagement_repository.dart';
import 'adoptable_animal_card.dart';

/// Widget für die Startseite - zeigt Engagement-Möglichkeiten
class EngagementWidget extends ConsumerWidget {
  const EngagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableEngagementWidget) {
      return const SizedBox.shrink();
    }

    final urgentAnimalsAsync = ref.watch(urgentAnimalsProvider);
    final urgentNeedsAsync = ref.watch(urgentNeedsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MshColors.engagementHeart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('❤️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hilfe gesucht',
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MshColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Engagiere dich in deiner Region',
                      style: TextStyle(
                        fontSize: 13,
                        color: MshColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation zu Engagement-Übersicht
                },
                child: const Text('Alle →'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Dringende Tiere
        urgentAnimalsAsync.when(
          data: (animals) {
            if (animals.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      const Text(
                        'Tiere suchen ein Zuhause',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: MshColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: MshColors.engagementHeart,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${animals.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: animals.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return AdoptableAnimalCard(
                        animalWithPlace: animals[index],
                        compact: true,
                        onTap: () {
                          // Öffne Tier-Detail
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const _LoadingPlaceholder(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 20),

        // Dringende Hilfsaufrufe
        urgentNeedsAsync.when(
          data: (needs) {
            if (needs.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('🆘', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      const Text(
                        'Dringende Hilfsaufrufe',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: MshColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...needs.take(3).map(
                      (needWithPlace) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: _NeedCard(needWithPlace: needWithPlace),
                      ),
                    ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NeedCard extends StatelessWidget {
  final EngagementNeedWithPlace needWithPlace;

  const _NeedCard({required this.needWithPlace});

  @override
  Widget build(BuildContext context) {
    final need = needWithPlace.need;
    final place = needWithPlace.place;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: need.urgency.color,
            width: 4,
          ),
        ),
        boxShadow: MshColors.cardShadow,
      ),
      child: Row(
        children: [
          // Kategorie Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: need.urgency.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                need.category.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        need.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: need.urgency.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        need.urgency.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MshColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: MshColors.slateMuted,
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(MshColors.engagementHeart),
        ),
      ),
    );
  }
}
