import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';

/// Erweitertes Analytics Dashboard mit detaillierten Statistiken
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
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
        title: const Text('MSH Analytics Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                AnalyticsService.clearCache();
                _analyticsData = AnalyticsService.loadAnalytics();
              });
            },
            tooltip: 'Aktualisieren',
          ),
        ],
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
            return _buildErrorView(context, snapshot.error.toString());
          }

          final data = snapshot.data!;
          return _buildDashboard(context, data);
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _analyticsData = AnalyticsService.loadAnalytics();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> data) {
    final overview = data['overview'] as Map<String, dynamic>;
    final byCategory = data['by_category'] as Map<String, dynamic>;
    final byCity = data['by_city'] as Map<String, dynamic>;
    final topCategories = data['top_categories'] as List<dynamic>;
    final topCities = data['top_cities'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Gesamt-Statistiken
          _buildOverviewSection(context, overview),
          const SizedBox(height: 24),

          // Top Kategorien als Karten-Grid
          _buildSectionHeader(context, 'Top Kategorien'),
          const SizedBox(height: 12),
          _buildCategoryGrid(context, topCategories),
          const SizedBox(height: 24),

          // Top Städte mit Fortschrittsbalken
          _buildSectionHeader(context, 'Top Städte'),
          const SizedBox(height: 12),
          _buildCityBars(context, topCities, overview['total_locations'] as int),
          const SizedBox(height: 24),

          // Alle Kategorien - Vollständige Liste
          _buildSectionHeader(context, 'Kategorien im Detail'),
          const SizedBox(height: 12),
          _buildCategoryDetails(context, byCategory),
          const SizedBox(height: 24),

          // Alle Städte - Vollständige Liste
          _buildSectionHeader(context, 'Städte im Detail'),
          const SizedBox(height: 12),
          _buildCityDetails(context, byCity),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, Map<String, dynamic> overview) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Mansfeld-Südharz Region',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  context,
                  '${overview['total_locations']}',
                  'Locations',
                  Icons.location_on,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  '${overview['total_cities']}',
                  'Städte',
                  Icons.location_city,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  '${overview['total_categories']}',
                  'Kategorien',
                  Icons.category,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<dynamic> topCategories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: topCategories.length > 6 ? 6 : topCategories.length,
      itemBuilder: (context, index) {
        final item = topCategories[index] as List<dynamic>;
        final name = item[0] as String;
        final count = item[1] as int;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(name),
                  size: 32,
                  color: Colors.blue[700],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCityBars(BuildContext context, List<dynamic> topCities, int total) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: topCities.take(5).map((cityData) {
            final item = cityData as List<dynamic>;
            final name = item[0] as String;
            final count = item[1] as int;
            final percentage = (count / total * 100).toInt();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Text(
                        '$count ($percentage%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count / total,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryDetails(BuildContext context, Map<String, dynamic> byCategory) {
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sorted.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sorted[index];
          final name = entry.key;
          final count = entry.value as int;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(
                _getCategoryIcon(name),
                color: Colors.blue[700],
                size: 20,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
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
          );
        },
      ),
    );
  }

  Widget _buildCityDetails(BuildContext context, Map<String, dynamic> byCity) {
    final sorted = byCity.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sorted.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sorted[index];
          final name = entry.key;
          final count = entry.value as int;

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.location_city, color: Colors.white, size: 20),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange[900],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
