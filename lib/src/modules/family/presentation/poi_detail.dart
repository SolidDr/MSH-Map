import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../shared/widgets/reviews_section.dart';
import '../../../shared/widgets/transport_buttons.dart';
import '../domain/poi.dart';

class PoiDetailContent extends StatelessWidget {
  const PoiDetailContent({required this.poi, super.key});

  final Poi poi;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            poi.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Kategorie Badge
          _CategoryBadge(category: poi.poiCategory),
          const SizedBox(height: 16),

          // Beschreibung
          if (poi.description != null) ...[
            Text(
              poi.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Tags
          if (poi.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: poi.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),)
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Adresse
          if (poi.address != null || poi.city != null)
            _InfoRow(
              icon: Icons.location_on,
              label: 'Adresse',
              value: [poi.address, poi.city].whereType<String>().join(', '),
            ),

          // Öffnungszeiten mit Status
          if (poi.openingHours != null)
            _OpeningHoursRow(
              openingHours: poi.openingHours!,
              isOpen: poi.isOpenNow,
            ),

          // Preis
          if (poi.priceInfo != null)
            _InfoRow(
              icon: Icons.euro,
              label: 'Preis',
              value: poi.priceInfo!,
            ),

          // Kostenlos
          if (poi.isFree)
            const _InfoRow(
              icon: Icons.money_off,
              label: 'Eintritt',
              value: 'Kostenlos',
            ),

          // Altersgruppe
          _InfoRow(
            icon: Icons.family_restroom,
            label: 'Altersgruppe',
            value: poi.ageRange,
          ),

          // Indoor/Outdoor
          if (poi.isIndoor || poi.isOutdoor)
            _InfoRow(
              icon: poi.isIndoor ? Icons.home : Icons.wb_sunny,
              label: 'Typ',
              value: poi.isIndoor && poi.isOutdoor
                  ? 'Indoor & Outdoor'
                  : poi.isIndoor
                      ? 'Indoor'
                      : 'Outdoor',
            ),

          // Barrierefrei
          if (poi.isBarrierFree)
            const _InfoRow(
              icon: Icons.accessible,
              label: 'Barrierefrei',
              value: 'Ja',
            ),

          // Einrichtungen
          if (poi.facilities.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.check_circle,
              label: 'Einrichtungen',
              value: poi.facilities.join(', '),
            ),
          ],

          // ÖPNV / Anreise
          const Divider(height: 32),
          TransportButtons(
            latitude: poi.coordinates.latitude,
            longitude: poi.coordinates.longitude,
            placeName: poi.name,
          ),

          // Bewertungen
          const Divider(height: 32),
          ReviewsSection(
            poiId: poi.id,
            poiName: poi.name,
          ),

          // Kontakt
          if (poi.contactPhone != null || poi.contactEmail != null) ...[
            const Divider(height: 32),
            Text(
              'Kontakt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (poi.contactPhone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone),
                title: Text(poi.contactPhone!),
              ),
            if (poi.contactEmail != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email),
                title: Text(poi.contactEmail!),
              ),
          ],

          // Website
          if (poi.website != null) ...[
            const SizedBox(height: 16),
            Text(
              'Website: ${poi.website}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningHoursRow extends StatelessWidget {
  const _OpeningHoursRow({
    required this.openingHours,
    required this.isOpen,
  });

  final String openingHours;
  final bool? isOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Öffnungszeiten',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (isOpen != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen!
                              ? MshColors.success.withValues(alpha: 0.15)
                              : MshColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOpen! ? 'Geöffnet' : 'Geschlossen',
                          style: TextStyle(
                            color: isOpen! ? MshColors.success : MshColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  openingHours,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final PoiCategory category;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (category) {
      PoiCategory.nature => (Icons.park, 'Natur', MshColors.categoryNature),
      PoiCategory.museum => (Icons.museum, 'Museum', MshColors.categoryMuseum),
      PoiCategory.castle => (Icons.castle, 'Burg/Schloss', MshColors.categoryCastle),
      PoiCategory.pool => (Icons.pool, 'Schwimmbad', MshColors.categoryPool),
      PoiCategory.playground => (Icons.child_care, 'Spielplatz', MshColors.categoryPlayground),
      PoiCategory.zoo => (Icons.pets, 'Zoo/Tierpark', MshColors.categoryZoo),
      PoiCategory.farm => (Icons.agriculture, 'Bauernhof', MshColors.categoryFarm),
      PoiCategory.adventure => (Icons.landscape, 'Abenteuer', MshColors.categoryAdventure),
      PoiCategory.school => (Icons.school, 'Schule', MshColors.categorySchool),
      PoiCategory.kindergarten => (Icons.child_care, 'Kita', MshColors.categoryKindergarten),
      PoiCategory.library => (Icons.local_library, 'Bibliothek', MshColors.categoryLibrary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
