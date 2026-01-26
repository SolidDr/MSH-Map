# MSH Map - Vereinfachtes Setup (Ohne Backend)

Einfache Lösung **ohne** Vercel/Firebase Functions - Analytics werden lokal berechnet und in Flutter geladen.

## Übersicht

Anstatt serverlose Functions zu nutzen, verwenden wir:
- **Python Engine** → Berechnet Analytics lokal, exportiert JSON
- **Firestore** → Speichert nur Locations (keine Analytics)
- **Flutter Assets** → Lädt Analytics-JSON direkt in die App

**Vorteile:**
- ✅ Keine Backend-Kosten
- ✅ Keine Service Account Keys nötig
- ✅ Einfacheres Setup
- ✅ Schneller Start

**Nachteile:**
- ❌ Keine automatischen Updates (manuell via Python)
- ❌ Keine Firestore Triggers
- ❌ Analytics nicht live, sondern static

## Workflow

### 1. Seed-Daten exportieren

```bash
cd deepscan
python deepscan_main.py --seed
```

**Output:**
```
deepscan/output/
├── merged/
│   ├── msh_complete_*.json         # Vollständige Daten
│   ├── msh_complete_*.geojson      # GeoJSON für Karten
│   └── msh_firestore_*.json        # Firestore-Import Format
└── analytics/
    ├── report_*.json               # Analytics als JSON
    └── report_*.md                 # Human-readable Report
```

### 2. Locations in Firestore importieren

**Option A: Mit Python Script (empfohlen)**

```bash
# Google Cloud SDK installieren (falls nicht vorhanden)
# Windows: https://cloud.google.com/sdk/docs/install

# Application Default Credentials setzen
gcloud auth application-default login

# Firebase Admin SDK installieren
pip install firebase-admin

# Import starten
cd deepscan
python import_to_firestore.py
```

**Option B: Manuell via Python**

```python
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialisieren (Application Default Credentials)
firebase_admin.initialize_app()
db = firestore.client()

# Lade Export
with open('deepscan/output/merged/msh_firestore_XXXXXX.json') as f:
    data = json.load(f)

# Batch Import
batch = db.batch()
for loc_id, loc_data in data['locations'].items():
    batch.set(db.collection('locations').document(loc_id), loc_data)
batch.commit()

print(f"✅ {len(data['locations'])} Locations importiert!")
```

### 3. Analytics in Flutter integrieren

#### 3.1 JSON-Datei kopieren

Kopiere `deepscan/output/analytics/report_*.json` nach:
```
lib/assets/data/analytics.json
```

#### 3.2 pubspec.yaml aktualisieren

```yaml
flutter:
  assets:
    - assets/data/analytics.json
```

#### 3.3 Analytics Model erstellen

```dart
// lib/src/models/analytics_data.dart

class AnalyticsData {
  final RegionOverview overview;
  final Map<String, CityStats> cityStats;
  final List<Gap> gaps;
  final List<Insight> insights;

  AnalyticsData({
    required this.overview,
    required this.cityStats,
    required this.gaps,
    required this.insights,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      overview: RegionOverview.fromJson(json['overview']),
      cityStats: (json['cities'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CityStats.fromJson(value)),
      ),
      gaps: (json['gaps'] as List).map((e) => Gap.fromJson(e)).toList(),
      insights: (json['insights'] as List).map((e) => Insight.fromJson(e)).toList(),
    );
  }
}

class RegionOverview {
  final int totalLocations;
  final int totalCities;
  final Map<String, int> categoryTotals;

  RegionOverview({
    required this.totalLocations,
    required this.totalCities,
    required this.categoryTotals,
  });

  factory RegionOverview.fromJson(Map<String, dynamic> json) {
    return RegionOverview(
      totalLocations: json['total_locations'],
      totalCities: json['total_cities'],
      categoryTotals: Map<String, int>.from(json['category_totals']),
    );
  }
}

class CityStats {
  final String cityName;
  final int locationCount;
  final Map<String, int> categoryDistribution;
  final double coverageScore;
  final double familyScore;

  CityStats({
    required this.cityName,
    required this.locationCount,
    required this.categoryDistribution,
    required this.coverageScore,
    required this.familyScore,
  });

  factory CityStats.fromJson(Map<String, dynamic> json) {
    return CityStats(
      cityName: json['city_name'],
      locationCount: json['location_count'],
      categoryDistribution: Map<String, int>.from(json['category_distribution']),
      coverageScore: (json['coverage_score'] as num).toDouble(),
      familyScore: (json['family_score'] as num).toDouble(),
    );
  }
}

class Gap {
  final String id;
  final String gapType;
  final String severity;
  final String description;
  final String affectedArea;

  Gap({
    required this.id,
    required this.gapType,
    required this.severity,
    required this.description,
    required this.affectedArea,
  });

  factory Gap.fromJson(Map<String, dynamic> json) {
    return Gap(
      id: json['id'],
      gapType: json['gap_type'],
      severity: json['severity'],
      description: json['description'],
      affectedArea: json['affected_area'],
    );
  }
}

class Insight {
  final String id;
  final String type;
  final String title;
  final String description;

  Insight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
    );
  }
}
```

#### 3.4 Analytics Service erstellen

```dart
// lib/src/services/analytics_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/analytics_data.dart';

class AnalyticsService {
  static AnalyticsData? _cachedData;

  /// Lädt Analytics aus Assets
  static Future<AnalyticsData> loadAnalytics() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString = await rootBundle.loadString('assets/data/analytics.json');
    final json = jsonDecode(jsonString);

    _cachedData = AnalyticsData.fromJson(json);
    return _cachedData!;
  }

  /// Cached Analytics abrufen (oder laden falls nicht gecached)
  static Future<AnalyticsData> getAnalytics() async {
    return _cachedData ?? await loadAnalytics();
  }
}
```

#### 3.5 Dashboard-Screen erstellen

```dart
// lib/src/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../models/analytics_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<AnalyticsData> _analyticsData;

  @override
  void initState() {
    super.initState();
    _analyticsData = AnalyticsService.loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSH Map Dashboard'),
      ),
      body: FutureBuilder<AnalyticsData>(
        future: _analyticsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCard(data.overview),
                const SizedBox(height: 16),

                // Stadt-Statistiken
                _buildCityStatsSection(data.cityStats),
                const SizedBox(height: 16),

                // Gaps
                _buildGapsSection(data.gaps),
                const SizedBox(height: 16),

                // Insights
                _buildInsightsSection(data.insights),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(RegionOverview overview) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Region Übersicht', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Orte', overview.totalLocations.toString()),
                _buildStatItem('Städte', overview.totalCities.toString()),
                _buildStatItem('Kategorien', overview.categoryTotals.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildCityStatsSection(Map<String, CityStats> cityStats) {
    final sortedCities = cityStats.entries.toList()
      ..sort((a, b) => b.value.locationCount.compareTo(a.value.locationCount));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Städte', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...sortedCities.take(5).map((entry) {
              final stats = entry.value;
              return ListTile(
                title: Text(stats.cityName),
                subtitle: Text('${stats.locationCount} Orte'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Coverage: ${(stats.coverageScore * 100).toInt()}%'),
                    Text('Family: ${(stats.familyScore * 100).toInt()}%'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGapsSection(List<Gap> gaps) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Infrastruktur-Lücken', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...gaps.map((gap) {
              return ListTile(
                leading: Icon(
                  Icons.warning,
                  color: gap.severity == 'critical' ? Colors.red : Colors.orange,
                ),
                title: Text(gap.description),
                subtitle: Text(gap.affectedArea),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(List<Insight> insights) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Insights', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...insights.map((insight) {
              return ListTile(
                leading: _getInsightIcon(insight.type),
                title: Text(insight.title),
                subtitle: Text(insight.description),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Icon _getInsightIcon(String type) {
    switch (type) {
      case 'achievement':
        return const Icon(Icons.emoji_events, color: Colors.green);
      case 'gap':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'trend':
        return const Icon(Icons.trending_up, color: Colors.blue);
      case 'recommendation':
        return const Icon(Icons.lightbulb, color: Colors.amber);
      default:
        return const Icon(Icons.info);
    }
  }
}
```

## Analytics aktualisieren

Wenn sich Daten ändern:

1. **Python Engine neu laufen lassen**:
   ```bash
   cd deepscan
   python deepscan_main.py --seed
   ```

2. **Neue analytics.json kopieren**:
   ```bash
   cp output/analytics/report_XXXXXX.json ../lib/assets/data/analytics.json
   ```

3. **Flutter neu builden**:
   ```bash
   flutter pub get
   flutter run
   ```

4. **Optional: Locations in Firestore aktualisieren**:
   ```bash
   python import_to_firestore.py
   ```

## Nächste Schritte

1. ✅ Seed-Daten exportieren
2. ✅ Locations in Firestore importieren
3. ✅ Analytics-JSON in Flutter Assets kopieren
4. ✅ Dashboard-Screen in Flutter erstellen
5. 🚀 App starten und testen!

## Vorteile dieser Lösung

- **Einfach**: Kein Backend, keine komplizierte Auth
- **Schnell**: Analytics werden lokal berechnet
- **Kostenlos**: Keine Function-Kosten
- **Offline-fähig**: Analytics sind in der App gebündelt
- **Flexibel**: Bei Bedarf später auf Backend umstellen

## Migration zu Backend (später)

Falls du später doch ein Backend möchtest:
- [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md) - Vercel Functions (kostenlos)
- [deepscan/README.md](./deepscan/README.md) - Firebase Functions (Blaze Plan)

Die Python Engine und Datenstrukturen bleiben gleich!
