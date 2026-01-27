import 'package:flutter/material.dart';
import '../domain/restaurant.dart';

class RestaurantDetailContent extends StatelessWidget {

  const RestaurantDetailContent({required this.restaurant, super.key});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (restaurant.todaySpecial != null) ...[
          const _SectionTitle('Tagesangebot'),
          _InfoCard(
            icon: Icons.restaurant_menu,
            title: restaurant.todaySpecial!,
            subtitle: restaurant.todayPrice != null
                ? '${restaurant.todayPrice!.toStringAsFixed(2)} €'
                : null,
          ),
          const SizedBox(height: 16),
        ],
        if (restaurant.address != null) ...[
          const _SectionTitle('Adresse'),
          _InfoCard(icon: Icons.location_on, title: restaurant.address!),
          const SizedBox(height: 16),
        ],
        if (restaurant.phone != null) ...[
          const _SectionTitle('Kontakt'),
          _InfoCard(icon: Icons.phone, title: restaurant.phone!),
          const SizedBox(height: 16),
        ],
        if (restaurant.openingHours.isNotEmpty) ...[
          const _SectionTitle('Öffnungszeiten'),
          ...restaurant.openingHours.map(
            (h) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(h),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {

  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InfoCard extends StatelessWidget {

  const _InfoCard({required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
      ),
    );
  }
}
