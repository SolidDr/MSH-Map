import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../domain/engagement_model.dart';
import '../data/engagement_repository.dart';

/// Karte für ein adoptierbares Tier
/// Mit Bild, Details und Dringlichkeits-Anzeige
class AdoptableAnimalCard extends StatelessWidget {

  const AdoptableAnimalCard({
    required this.animalWithPlace, super.key,
    this.onTap,
    this.compact = false,
  });
  final AdoptableAnimalWithPlace animalWithPlace;
  final VoidCallback? onTap;
  final bool compact;

  AdoptableAnimal get animal => animalWithPlace.animal;
  EngagementPlace get place => animalWithPlace.place;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: animal.isUrgent || animal.isLongStay
              ? Border.all(color: MshColors.engagementHeart, width: 2)
              : null,
          boxShadow: MshColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bild
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildImage(height: 100),
                ),
                // Tierart Badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      animal.type.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                // Dringlichkeits-Badge
                if (animal.isUrgent || animal.isLongStay)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MshColors.engagementHeart,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        animal.isUrgent ? 'Dringend' : 'Lange wartend',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [animal.breed, animal.age].whereType<String>().join(' • '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: MshColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: MshColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.city ?? place.name,
                          style: const TextStyle(
                            fontSize: 10,
                            color: MshColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: animal.isUrgent || animal.isLongStay
              ? Border.all(color: MshColors.engagementHeart, width: 2)
              : null,
          boxShadow: MshColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bild mit Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildImage(height: 180),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Tierart Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(animal.type.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          animal.type.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dringlichkeits-Banner
                if (animal.isUrgent || animal.isLongStay)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: MshColors.engagementHeart,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            animal.isUrgent
                                ? 'Sucht dringend!'
                                : '${animal.waitingDays} Tage wartend',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Name Overlay unten
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      if (animal.breed != null)
                        Text(
                          animal.breed!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eigenschaften
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (animal.age != null)
                        _PropertyChip(icon: Icons.cake_outlined, label: animal.age!),
                      if (animal.gender != null)
                        _PropertyChip(
                          icon: animal.gender == 'männlich'
                              ? Icons.male
                              : Icons.female,
                          label: animal.gender!,
                        ),
                      if (animal.size != null)
                        _PropertyChip(icon: Icons.straighten, label: animal.size!),
                    ],
                  ),

                  // Beschreibung
                  if (animal.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      animal.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: MshColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Charakter
                  if (animal.character != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('💝', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            animal.character!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: MshColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Tierheim Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MshColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: MshColors.engagementAnimal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('🏠', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                place.city ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MshColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: MshColors.slateMuted,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Text('❤️', style: TextStyle(fontSize: 18)),
                      label: const Text('Kennenlernen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MshColors.engagementHeart,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({required double height}) {
    if (animal.imageUrl != null && animal.imageUrl!.isNotEmpty) {
      return Image.asset(
        animal.imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(height),
      );
    }
    return _buildPlaceholder(height);
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: MshColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              animal.type.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            const Text(
              'Foto kommt bald',
              style: TextStyle(
                color: MshColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {

  const _PropertyChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MshColors.copperSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: MshColors.copper),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: MshColors.copper,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
