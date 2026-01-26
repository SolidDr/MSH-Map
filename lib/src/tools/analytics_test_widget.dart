import 'package:flutter/material.dart';
import '../core/services/analytics_service.dart';

/// Test-Widget zum Anzeigen der Analytics-Daten aus Assets
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const AnalyticsTestWidget()),
/// );
/// ```
class AnalyticsTestWidget extends StatefulWidget {
  const AnalyticsTestWidget({super.key});

  @override
  State<AnalyticsTestWidget> createState() => _AnalyticsTestWidgetState();
}

class _AnalyticsTestWidgetState extends State<AnalyticsTestWidget> {
  late Future<Map<String, dynamic>> _analyticsData;

  @override
  void initState() {
    super.initState();
    _analyticsData = AnalyticsService.loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSH Analytics Test'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Fehler beim Laden',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final overview = data['overview'] as Map<String, dynamic>;
          final topCategories = data['top_categories'] as List<dynamic>;
          final topCities = data['top_cities'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Analytics erfolgreich geladen!',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Overview Cards
                _buildSectionTitle('Übersicht'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Locations',
                        '${overview['total_locations']}',
                        Icons.location_on,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Städte',
                        '${overview['total_cities']}',
                        Icons.location_city,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Kategorien',
                        '${overview['total_categories']}',
                        Icons.category,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Top Categories
                _buildSectionTitle('Top Kategorien'),
                const SizedBox(height: 12),
                _buildTopList(
                  topCategories.take(5).map((item) {
                    final list = item as List<dynamic>;
                    return {'name': list[0] as String, 'count': list[1] as int};
                  }).toList(),
                  _getCategoryIcon,
                ),
                const SizedBox(height: 32),

                // Top Cities
                _buildSectionTitle('Top Städte'),
                const SizedBox(height: 12),
                _buildTopList(
                  topCities.take(5).map((item) {
                    final list = item as List<dynamic>;
                    return {'name': list[0] as String, 'count': list[1] as int};
                  }).toList(),
                  (_) => Icons.location_city,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopList(
    List<Map<String, dynamic>> items,
    IconData Function(String) getIcon,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final name = item['name'] as String;
          final count = item['count'] as int;

          return Column(
            children: [
              if (index > 0) const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(getIcon(name), color: Colors.blue.shade700, size: 20),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'nature':
        return Icons.forest;
      case 'castle':
        return Icons.castle;
      case 'culture':
        return Icons.theater_comedy;
      case 'pool':
        return Icons.pool;
      case 'museum':
        return Icons.museum;
      case 'zoo':
        return Icons.pets;
      case 'restaurant':
        return Icons.restaurant;
      case 'adventure':
        return Icons.hiking;
      case 'playground':
        return Icons.child_friendly;
      case 'farm':
        return Icons.agriculture;
      case 'cafe':
        return Icons.local_cafe;
      case 'imbiss':
        return Icons.fastfood;
      case 'indoor':
        return Icons.home;
      case 'event':
        return Icons.event;
      case 'sport':
        return Icons.sports;
      default:
        return Icons.place;
    }
  }
}
