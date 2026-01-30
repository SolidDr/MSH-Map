import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/msh_colors.dart';
import '../domain/pool.dart';

/// Detail-Widget für Schwimmbäder
class PoolDetailContent extends StatelessWidget {
  const PoolDetailContent({required this.pool, super.key});

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name und Typ
          Text(
            pool.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                pool.poolType == PoolType.indoor ? Icons.pool : Icons.wb_sunny,
                size: 16,
                color: MshColors.categoryPool,
              ),
              const SizedBox(width: 4),
              Text(
                pool.poolType.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MshColors.categoryPool,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Saisonhinweis
          if (pool.isSeasonal) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pool.seasonNote ?? 'Saisonabhängig geöffnet',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Beschreibung
          if (pool.description != null) ...[
            Text(
              pool.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Features
          if (pool.features.isNotEmpty) ...[
            Text(
              'Ausstattung',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pool.features
                  .map((feature) => Chip(
                        avatar: const Icon(Icons.check, size: 16),
                        label: Text(feature),
                        backgroundColor: MshColors.categoryPool.withAlpha(25),
                      ),)
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Aqua-Fitness Kurse
          if (pool.aquaFitness.isNotEmpty) ...[
            Text(
              'Aqua-Fitness Kurse',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...pool.aquaFitness.map((offer) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(offer.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (offer.description != null) Text(offer.description!),
                        if (offer.day != null)
                          Text(
                            offer.day!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        if (offer.requiresRegistration)
                          const Text(
                            'Anmeldung erforderlich',
                            style: TextStyle(
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: offer.description != null,
                  ),
                ),),
            const SizedBox(height: 16),
          ],

          // Kontaktdaten
          _buildInfoSection(context),

          // Features-Badges
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (pool.isBarrierFree)
                _buildFeatureChip(Icons.accessible, 'Barrierefrei'),
              if (pool.hasParking)
                _buildFeatureChip(Icons.local_parking, 'Parkplatz'),
              if (pool.familyFriendly)
                _buildFeatureChip(Icons.family_restroom, 'Familienfreundlich'),
            ],
          ),

          // Altersgruppen
          if (pool.ageGroups.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Geeignet für',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: pool.ageGroups
                  .map((age) => Chip(
                        avatar: const Icon(Icons.child_care, size: 16),
                        label: Text(_formatAgeGroup(age)),
                      ),)
                  .toList(),
            ),
          ],

          // Website Button
          if (pool.website != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(pool.website!),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Website öffnen'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: MshColors.categoryPool,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adresse
        if (pool.address != null || pool.city != null) ...[
          _buildInfoRow(
            context,
            Icons.location_on,
            'Adresse',
            pool.fullAddress,
          ),
          const SizedBox(height: 8),
        ],

        // Öffnungszeiten
        if (pool.openingHoursText != null) ...[
          _buildInfoRow(
            context,
            Icons.access_time,
            'Öffnungszeiten',
            pool.openingHoursText!,
          ),
          const SizedBox(height: 8),
        ],

        // Telefon
        if (pool.phone != null) ...[
          InkWell(
            onTap: () => _launchUrl('tel:${pool.phone}'),
            child: _buildInfoRow(
              context,
              Icons.phone,
              'Telefon',
              pool.phoneFormatted ?? pool.phone!,
              isLink: true,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // E-Mail
        if (pool.email != null) ...[
          InkWell(
            onTap: () => _launchUrl('mailto:${pool.email}'),
            child: _buildInfoRow(
              context,
              Icons.email,
              'E-Mail',
              pool.email!,
              isLink: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLink ? MshColors.categoryPool : null,
                      decoration: isLink ? TextDecoration.underline : null,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.blue[50],
    );
  }

  String _formatAgeGroup(String age) {
    return switch (age) {
      '0-3' => 'Babys (0-3)',
      '3-6' => 'Kleinkinder (3-6)',
      '6-12' => 'Kinder (6-12)',
      '12+' => 'Jugendliche (12+)',
      _ => age,
    };
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
