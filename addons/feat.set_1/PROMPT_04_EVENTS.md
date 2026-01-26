# PROMPT 4: Events auf Karte & Widget

## Kontext

Du arbeitest am MSH Map Projekt.
Feature-Flags, Altersfilter und Wetter sind bereits implementiert.
`FeatureFlags.enableEventsOnMap` und `FeatureFlags.enableEventsWidget` sind `true`.

## Deine Aufgabe

Implementiere:
1. Veranstaltungs-Marker auf der Karte
2. "Diese Woche" Widget für die Startseite
3. Events aus JSON laden

## Schritt 1: Event-Model erstellen

Erstelle `lib/src/features/events/domain/event_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class MshEvent with _$MshEvent {
  const MshEvent._();
  
  const factory MshEvent({
    required String id,
    required String name,
    required DateTime date,
    String? timeStart,
    String? timeEnd,
    required String locationName,
    double? latitude,
    double? longitude,
    required String city,
    required String category,
    String? description,
    String? price,
    String? sourceUrl,
    @Default([]) List<String> tags,
  }) = _MshEvent;
  
  factory MshEvent.fromJson(Map<String, dynamic> json) =>
      _$MshEventFromJson(json);
  
  /// Ist das Event heute?
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Ist das Event morgen?
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }
  
  /// Ist das Event diese Woche?
  bool get isThisWeek {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    return date.isAfter(now.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// Formatiertes Datum
  String get formattedDate {
    if (isToday) return 'Heute';
    if (isTomorrow) return 'Morgen';
    
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day}.${date.month}.';
  }
  
  /// Kategorie-Farbe
  Color get categoryColor {
    return EventCategory.fromString(category).color;
  }
  
  /// Kategorie-Icon
  IconData get categoryIcon {
    return EventCategory.fromString(category).icon;
  }
  
  /// Kategorie-Emoji
  String get categoryEmoji {
    return EventCategory.fromString(category).emoji;
  }
}

enum EventCategory {
  konzert('konzert', 'Konzert', Icons.music_note, Colors.purple, '🎵'),
  markt('markt', 'Markt', Icons.storefront, Colors.orange, '🏪'),
  theater('theater', 'Theater', Icons.theater_comedy, Colors.red, '🎭'),
  sport('sport', 'Sport', Icons.sports_soccer, Colors.green, '⚽'),
  kinder('kinder', 'Kinder', Icons.child_care, Colors.pink, '👶'),
  fest('fest', 'Fest', Icons.celebration, Colors.amber, '🎉'),
  fuehrung('fuehrung', 'Führung', Icons.directions_walk, Colors.blue, '🚶'),
  ausstellung('ausstellung', 'Ausstellung', Icons.museum, Colors.teal, '🖼️'),
  sonstiges('sonstiges', 'Sonstiges', Icons.event, Colors.grey, '📅');

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String emoji;

  const EventCategory(this.id, this.label, this.icon, this.color, this.emoji);

  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (c) => c.id == value.toLowerCase(),
      orElse: () => EventCategory.sonstiges,
    );
  }
}
```

## Schritt 2: Event-Repository

Erstelle `lib/src/features/events/data/event_repository.dart`:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/event_model.dart';

class EventRepository {
  List<MshEvent>? _cachedEvents;
  
  /// Lädt Events aus der JSON-Datei
  Future<List<MshEvent>> getEvents() async {
    if (_cachedEvents != null) return _cachedEvents!;
    
    try {
      final jsonString = await rootBundle.loadString(
        'data/events/events_current.json'
      );
      final json = jsonDecode(jsonString);
      final eventsJson = json['events'] as List;
      
      _cachedEvents = eventsJson
          .map((e) => MshEvent.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return _cachedEvents!;
    } catch (e) {
      // Fallback: Mock-Events
      return _getMockEvents();
    }
  }
  
  /// Events der nächsten X Tage
  Future<List<MshEvent>> getUpcomingEvents({int days = 14}) async {
    final events = await getEvents();
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: days));
    
    return events
        .where((e) => e.date.isAfter(now.subtract(const Duration(days: 1))))
        .where((e) => e.date.isBefore(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  
  /// Events für einen bestimmten Tag
  Future<List<MshEvent>> getEventsForDate(DateTime date) async {
    final events = await getEvents();
    return events.where((e) => 
      e.date.year == date.year && 
      e.date.month == date.month && 
      e.date.day == date.day
    ).toList();
  }
  
  /// Events mit Koordinaten (für Karte)
  Future<List<MshEvent>> getEventsWithCoordinates() async {
    final events = await getUpcomingEvents();
    return events.where((e) => 
      e.latitude != null && e.longitude != null
    ).toList();
  }
  
  /// Mock-Events als Fallback
  List<MshEvent> _getMockEvents() {
    final now = DateTime.now();
    return [
      MshEvent(
        id: 'evt_001',
        name: 'Wochenmarkt Sangerhausen',
        date: now.add(Duration(days: (6 - now.weekday) % 7)), // Nächster Samstag
        timeStart: '08:00',
        timeEnd: '13:00',
        locationName: 'Marktplatz',
        latitude: 51.4698,
        longitude: 11.2978,
        city: 'Sangerhausen',
        category: 'markt',
        description: 'Frische regionale Produkte',
        price: 'kostenlos',
      ),
      MshEvent(
        id: 'evt_002',
        name: 'Familienführung Rosarium',
        date: now.add(const Duration(days: 2)),
        timeStart: '14:00',
        timeEnd: '16:00',
        locationName: 'Europa-Rosarium',
        latitude: 51.4725,
        longitude: 11.2983,
        city: 'Sangerhausen',
        category: 'fuehrung',
        description: 'Kinderfreundliche Führung durch das Rosarium',
        price: '8,00 €',
      ),
      MshEvent(
        id: 'evt_003',
        name: 'Konzert Mammuthalle',
        date: now.add(const Duration(days: 5)),
        timeStart: '20:00',
        locationName: 'Mammuthalle',
        latitude: 51.4701,
        longitude: 11.2956,
        city: 'Sangerhausen',
        category: 'konzert',
        description: 'Live-Musik',
        price: '15,00 €',
      ),
    ];
  }
}
```

## Schritt 3: Event-Provider

Erstelle `lib/src/features/events/application/event_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/event_repository.dart';
import '../domain/event_model.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

/// Alle kommenden Events (14 Tage)
final upcomingEventsProvider = FutureProvider<List<MshEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).getUpcomingEvents();
});

/// Events mit Koordinaten (für Karte)
final mapEventsProvider = FutureProvider<List<MshEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).getEventsWithCoordinates();
});

/// Events gruppiert nach Datum
final groupedEventsProvider = FutureProvider<Map<DateTime, List<MshEvent>>>((ref) async {
  final events = await ref.watch(upcomingEventsProvider.future);
  
  final grouped = <DateTime, List<MshEvent>>{};
  for (final event in events) {
    final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);
    grouped.putIfAbsent(dateOnly, () => []).add(event);
  }
  
  return Map.fromEntries(
    grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
  );
});

/// Anzahl Events diese Woche
final thisWeekEventCountProvider = FutureProvider<int>((ref) async {
  final events = await ref.watch(upcomingEventsProvider.future);
  return events.where((e) => e.isThisWeek).length;
});
```

## Schritt 4: Event-Marker für Karte

Erstelle `lib/src/features/events/presentation/event_map_layer.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../application/event_provider.dart';
import '../domain/event_model.dart';
import '../../../core/config/feature_flags.dart';

class EventMapLayer extends ConsumerWidget {
  const EventMapLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableEventsOnMap) {
      return const SizedBox.shrink();
    }
    
    final eventsAsync = ref.watch(mapEventsProvider);
    
    return eventsAsync.when(
      data: (events) => MarkerLayer(
        markers: events.map((event) => Marker(
          point: LatLng(event.latitude!, event.longitude!),
          width: 36,
          height: 36,
          child: _EventMarker(event: event),
        )).toList(),
      ),
      loading: () => const MarkerLayer(markers: []),
      error: (_, __) => const MarkerLayer(markers: []),
    );
  }
}

class _EventMarker extends StatelessWidget {
  final MshEvent event;

  const _EventMarker({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEventDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: event.categoryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            event.categoryIcon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventDetailSheet(event: event),
    );
  }
}

class EventDetailSheet extends StatelessWidget {
  final MshEvent event;

  const EventDetailSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Kategorie Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: event.categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(event.categoryEmoji),
                    const SizedBox(width: 4),
                    Text(
                      EventCategory.fromString(event.category).label,
                      style: TextStyle(
                        color: event.categoryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Name
              Text(
                event.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Datum & Zeit
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    event.formattedDate,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (event.timeStart != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      event.timeEnd != null
                          ? '${event.timeStart} - ${event.timeEnd}'
                          : event.timeStart!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              
              // Ort
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${event.locationName}, ${event.city}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              
              // Preis
              if (event.price != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.euro, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      event.price!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: event.price == 'kostenlos' 
                            ? Colors.green 
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Beschreibung
              if (event.description != null) ...[
                const Divider(height: 32),
                Text(
                  event.description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              
              // Link zur Quelle
              if (event.sourceUrl != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _openUrl(event.sourceUrl!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Mehr Infos'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  void _openUrl(String url) {
    // launchUrl(Uri.parse(url));
  }
}
```

## Schritt 5: "Diese Woche" Widget

Erstelle `lib/src/features/events/presentation/upcoming_events_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/event_provider.dart';
import '../domain/event_model.dart';
import '../../../core/config/feature_flags.dart';

class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableEventsWidget) {
      return const SizedBox.shrink();
    }
    
    final groupedAsync = ref.watch(groupedEventsProvider);
    
    return groupedAsync.when(
      data: (grouped) => _EventsList(groupedEvents: grouped),
      loading: () => const _EventsLoading(),
      error: (_, __) => const _EventsError(),
    );
  }
}

class _EventsList extends StatelessWidget {
  final Map<DateTime, List<MshEvent>> groupedEvents;

  const _EventsList({required this.groupedEvents});

  @override
  Widget build(BuildContext context) {
    if (groupedEvents.isEmpty) {
      return const _NoEvents();
    }
    
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.event, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Diese Woche',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigation zu allen Events
                },
                child: const Text('Alle'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Events nach Datum
        ...groupedEvents.entries.take(5).map((entry) {
          final date = entry.key;
          final events = entry.value;
          
          return _DateSection(date: date, events: events);
        }),
      ],
    );
  }
}

class _DateSection extends StatelessWidget {
  final DateTime date;
  final List<MshEvent> events;

  const _DateSection({required this.date, required this.events});

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Datum-Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isToday 
                    ? theme.colorScheme.primary 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Event-Karten (horizontal scrollbar)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _EventCard(event: events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  String _formatDate(DateTime date) {
    if (_isToday(date)) return 'Heute';
    
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Morgen';
    }
    
    final weekdays = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
    return '${weekdays[date.weekday - 1]}, ${date.day}.${date.month}.';
  }
}

class _EventCard extends StatelessWidget {
  final MshEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategorie + Zeit
              Row(
                children: [
                  Text(event.categoryEmoji),
                  const SizedBox(width: 4),
                  if (event.timeStart != null)
                    Text(
                      event.timeStart!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  const Spacer(),
                  if (event.price == 'kostenlos')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Gratis',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Name
              Text(
                event.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Ort
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      event.city,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventDetailSheet(event: event),
    );
  }
}

class _EventsLoading extends StatelessWidget {
  const _EventsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EventsError extends StatelessWidget {
  const _EventsError();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: Text('Events konnten nicht geladen werden')),
    );
  }
}

class _NoEvents extends StatelessWidget {
  const _NoEvents();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Keine Veranstaltungen diese Woche',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Schritt 6: In Karte integrieren

Im Map-Widget, füge den Event-Layer hinzu:

```dart
FlutterMap(
  options: MapOptions(...),
  children: [
    TileLayer(...),
    
    // Fog of War
    if (FeatureFlags.enableFogOfWar)
      const FogOfWarLayer(),
    
    // Locations
    LocationMarkerLayer(...),
    
    // Events (NEU)
    if (FeatureFlags.enableEventsOnMap)
      const EventMapLayer(),
  ],
)
```

## Schritt 7: In Home einbauen

```dart
Column(
  children: [
    // Wetter
    if (FeatureFlags.enableWeather)
      const WeatherWidget(),
    
    // Events (NEU)
    if (FeatureFlags.enableEventsWidget)
      const UpcomingEventsWidget(),
    
    // ... Rest
  ],
)
```

## Schritt 8: JSON-Datei erstellen

Erstelle `assets/data/events/events_current.json`:

```json
{
  "meta": {
    "generated_at": "2025-01-27T10:00:00Z",
    "kw": 5
  },
  "events": [
    {
      "id": "evt_001",
      "name": "Wochenmarkt Sangerhausen",
      "date": "2025-02-01",
      "timeStart": "08:00",
      "timeEnd": "13:00",
      "locationName": "Marktplatz",
      "latitude": 51.4698,
      "longitude": 11.2978,
      "city": "Sangerhausen",
      "category": "markt",
      "description": "Frische regionale Produkte",
      "price": "kostenlos"
    }
  ]
}
```

In `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/data/events/
```

## Abschluss

Nach Fertigstellung:
- [ ] Event-Model mit Kategorien erstellt
- [ ] Repository mit JSON-Loading + Mock-Fallback
- [ ] Provider für State
- [ ] EventMapLayer zeigt Marker auf Karte
- [ ] UpcomingEventsWidget zeigt "Diese Woche"
- [ ] EventDetailSheet für Details
- [ ] JSON-Datei erstellt
- [ ] Feature-Flags integriert
- [ ] In Map und Home eingebaut

Zeige mir eine Zusammenfassung.
