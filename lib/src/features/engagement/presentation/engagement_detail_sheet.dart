import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/msh_colors.dart';
import '../domain/engagement_model.dart';
import '../data/engagement_repository.dart';
import 'adoptable_animal_card.dart';

/// Detail-Sheet für einen Engagement-Ort
/// Zeigt alle Infos, Tiere und Hilfsbedarfe
class EngagementDetailSheet extends StatelessWidget {
  final EngagementPlace place;

  const EngagementDetailSheet({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: MshColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MshColors.slateMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Kontakt-Infos
                    if (place.phone != null ||
                        place.website != null ||
                        place.openingHours != null)
                      _buildContactSection(),

                    // Aktuelle Hilfsbedarfe
                    if (place.currentNeeds.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildNeedsSection(),
                    ],

                    // Adoptierbare Tiere
                    if (place.adoptableAnimals.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildAnimalsSection(),
                    ],

                    const SizedBox(height: 24),
                    _buildCTAButtons(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: place.type.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                place.type.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontFamily: 'Merriweather',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: MshColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: place.type.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.type.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: place.type.color,
                          ),
                        ),
                      ),
                      if (place.isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: MshColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 12,
                                color: MshColors.success,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Verifiziert',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: MshColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (place.city != null || place.description != null) ...[
          const SizedBox(height: 16),
          if (place.city != null)
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: MshColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  place.city!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MshColors.textSecondary,
                  ),
                ),
              ],
            ),
          if (place.description != null) ...[
            const SizedBox(height: 12),
            Text(
              place.description!,
              style: const TextStyle(
                fontSize: 14,
                color: MshColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: MshColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kontakt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (place.openingHours != null)
            _buildContactRow(
              Icons.access_time,
              'Öffnungszeiten',
              place.openingHours!,
            ),
          if (place.phone != null)
            _buildContactRow(
              Icons.phone_outlined,
              'Telefon',
              place.phone!,
              onTap: () => _launchPhone(place.phone!),
            ),
          if (place.website != null)
            _buildContactRow(
              Icons.language,
              'Website',
              place.website!,
              onTap: () => _launchUrl(place.website!),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: MshColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: MshColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: onTap != null ? MshColors.primary : MshColors.textPrimary,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.open_in_new,
                size: 16,
                color: MshColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🆘', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text(
              'Aktuelle Hilfsbedarfe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...place.currentNeeds.map(
          (need) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NeedCard(need: need),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🐾', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text(
              'Tiere suchen ein Zuhause',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MshColors.engagementHeart,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${place.adoptableAnimals.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: place.adoptableAnimals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return AdoptableAnimalCard(
                animalWithPlace: AdoptableAnimalWithPlace(
                  animal: place.adoptableAnimals[index],
                  place: place,
                ),
                compact: true,
                onTap: () {
                  // TODO: Navigate to animal detail
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return Column(
      children: [
        if (place.website != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(place.website!),
              icon: const Icon(Icons.language),
              label: const Text('Website besuchen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: place.type.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (place.phone != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchPhone(place.phone!),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Anrufen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: place.type.color,
                    side: BorderSide(color: place.type.color),
                  ),
                ),
              ),
            if (place.phone != null) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchMaps(place.latitude, place.longitude),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Navigation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: place.type.color,
                  side: BorderSide(color: place.type.color),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _NeedCard extends StatelessWidget {
  final EngagementNeed need;

  const _NeedCard({required this.need});

  @override
  Widget build(BuildContext context) {
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
          // Icon
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
                  need.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MshColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
