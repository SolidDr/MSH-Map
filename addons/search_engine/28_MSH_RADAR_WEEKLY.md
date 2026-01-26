# 28 - MSH RADAR: Wöchentlicher Update-Workflow

## Konzept: "Einmal die Woche, 30 Minuten, alles aktuell"

Du startest einmal pro Woche Claude Code mit diesem Prompt. Claude recherchiert, sammelt, aktualisiert - und du machst in der Zeit Pause oder arbeitest an was anderem.

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   DEIN WORKFLOW (Sonntag Abend oder Montag Morgen)         │
│                                                             │
│   1. VS Code öffnen                                         │
│   2. Claude Code starten                                    │
│   3. Prompt einfügen: "MSH Radar starten"                  │
│   4. Kaffee holen ☕ (20-30 Min)                            │
│   5. Zurückkommen, Ergebnis prüfen                         │
│   6. "Freigabe!" → Claude pusht zu Vercel                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## TEIL 1: Was der MSH Radar sammelt

### 1.1 Veranstaltungen (Hauptfokus!)

| Quelle | URL | Daten |
|--------|-----|-------|
| **MZ Events** | mz.de/veranstaltungen | Konzerte, Theater, Feste |
| **Sangerhausen.de** | sangerhausen.de/veranstaltungen | Städtische Events |
| **Eisleben.eu** | eisleben.eu/aktuelles | Luther-Events, Märkte |
| **Südharz** | suedharzinfo.de | Wanderungen, Feste |
| **Harz Tourismus** | harzinfo.de/veranstaltungen | Regionale Highlights |
| **Facebook Events** | (manuell, kein Scraping) | Vereins-Events |

**Gesammelte Infos pro Event:**
- Name
- Datum & Uhrzeit
- Ort (mit Koordinaten)
- Beschreibung
- Kategorie (Konzert, Markt, Sport, Kinder, etc.)
- Eintritt (kostenlos/Preis)
- Link zur Quelle

### 1.2 Aktuelle Hinweise & Warnungen

| Typ | Quelle | Beispiel |
|-----|--------|----------|
| **Straßensperrungen** | Gemeinde-Websites | "B86 gesperrt 15.-20.01." |
| **Baustellen** | Presse/Gemeinden | "Marktplatz Sanierung" |
| **Wetterwarnungen** | DWD (falls relevant) | "Sturmwarnung" |
| **Sonderöffnungszeiten** | Websites der Orte | "Rosarium Winterpause" |
| **Neue Orte** | Pressemeldungen | "Neuer Spielplatz eröffnet" |

### 1.3 Updates zu bestehenden Orten

- Neue Bewertungen (Google, etc.)
- Geänderte Öffnungszeiten
- Saisonale Infos (Freibad geschlossen, etc.)
- Preisänderungen

---

## TEIL 2: Der Prompt für Claude Code

### Haupt-Prompt: `MSH_RADAR_PROMPT.md`

```markdown
# MSH RADAR - Wöchentlicher Update-Scan

## Deine Aufgabe

Du führst den wöchentlichen MSH Radar Scan durch. Das dauert 20-30 Minuten.
Der Nutzer macht in der Zeit Pause - arbeite selbstständig und gründlich.

## Schritt 1: Veranstaltungen sammeln (10-15 Min)

Recherchiere Veranstaltungen für die nächsten 14 Tage in der Region MSH.

### Quellen durchsuchen:

1. **MZ Veranstaltungskalender**
   - URL: https://www.mz.de/veranstaltungen
   - Filter: Mansfeld-Südharz, Sangerhausen, Eisleben
   - Suche nach: Konzerte, Theater, Märkte, Feste, Sport

2. **Sangerhausen.de**
   - URL: https://www.sangerhausen.de
   - Suche: "Veranstaltungen", "Aktuelles", "Termine"

3. **Südharz Info**
   - URL: https://www.suedharzinfo.de
   - Events, Wanderungen, Führungen

4. **Harz Tourismus**
   - URL: https://www.harzinfo.de/veranstaltungen
   - Regionale Events

### Für jedes Event erfasse:

```json
{
  "id": "event_YYYYMMDD_001",
  "name": "Name der Veranstaltung",
  "date": "2025-01-25",
  "time_start": "19:00",
  "time_end": "22:00",
  "location_name": "Mammuthalle Sangerhausen",
  "latitude": 51.4698,
  "longitude": 11.2978,
  "city": "Sangerhausen",
  "category": "konzert|markt|theater|sport|kinder|fest|führung|sonstiges",
  "description": "Kurze Beschreibung...",
  "price": "kostenlos" | "12,00 €" | "Eintritt frei",
  "source_url": "https://...",
  "tags": ["musik", "familie", "outdoor"]
}
```

## Schritt 2: Hinweise & Warnungen prüfen (5 Min)

Suche nach:
- Straßensperrungen in MSH
- Baustellen die Orte betreffen
- Sonderöffnungszeiten (Feiertage, Ferien)
- Wichtige Meldungen der Städte

### Erfasse als:

```json
{
  "id": "notice_001",
  "type": "sperrung|baustelle|oeffnungszeit|warnung|info",
  "title": "B86 Vollsperrung",
  "description": "Zwischen Sangerhausen und...",
  "affected_area": "Sangerhausen - Kelbra",
  "valid_from": "2025-01-20",
  "valid_until": "2025-01-25",
  "severity": "info|warning|critical",
  "source_url": "https://..."
}
```

## Schritt 3: Orts-Updates prüfen (5 Min)

Prüfe für die Top-20 Orte:
- Haben sich Öffnungszeiten geändert?
- Gibt es Saisonschließungen?
- Neue Infos auf deren Websites?

Nur echte Änderungen notieren!

## Schritt 4: Daten zusammenführen

Erstelle/Aktualisiere diese Dateien:

```
msh_map/
├── data/
│   ├── events/
│   │   └── events_current.json      ← Alle Events nächste 14 Tage
│   ├── notices/
│   │   └── notices_current.json     ← Aktuelle Hinweise
│   └── updates/
│       └── location_updates.json    ← Änderungen an Orten
```

## Schritt 5: Report erstellen

Erstelle `RADAR_REPORT_[DATUM].md`:

```markdown
# MSH Radar Report - KW XX/2025

## Zusammenfassung
- X neue Veranstaltungen gefunden
- X Hinweise/Warnungen aktiv
- X Orts-Updates

## Highlights diese Woche
- [Top Event 1]
- [Top Event 2]
- [Wichtige Warnung falls vorhanden]

## Veranstaltungen (nächste 14 Tage)

### Samstag, 25.01.
| Zeit | Event | Ort | Kategorie |
|------|-------|-----|-----------|
| 19:00 | Konzert XY | Mammuthalle | Musik |

### Sonntag, 26.01.
...

## Aktive Hinweise
- ⚠️ B86 Sperrung bis 25.01.
- ℹ️ Rosarium Winteröffnungszeiten

## Änderungen an Orten
- Europa-Rosarium: Winteröffnungszeiten aktualisiert
- ...

---
Scan durchgeführt: [Datum/Uhrzeit]
Quellen: MZ, Sangerhausen.de, Südharz-Info, Harz-Tourismus
```

## Schritt 6: Web-Daten aktualisieren

Aktualisiere die JSON-Dateien die die Web-App lädt:

```dart
// In data/events_current.json
{
  "generated_at": "2025-01-20T10:30:00",
  "valid_until": "2025-02-03",
  "events": [...],
  "notices": [...],
  "stats": {
    "total_events": 23,
    "this_week": 12,
    "next_week": 11,
    "categories": {
      "konzert": 5,
      "markt": 3,
      ...
    }
  }
}
```

## Schritt 7: Abschluss

Wenn fertig, zeige dem Nutzer:

```
✅ MSH RADAR SCAN ABGESCHLOSSEN

📊 Ergebnisse:
   • 23 Veranstaltungen gefunden
   • 3 aktive Hinweise
   • 2 Orts-Updates

📅 Zeitraum: 20.01. - 03.02.2025

📝 Report: RADAR_REPORT_2025-01-20.md

🔍 Bitte prüfen:
   1. Events korrekt?
   2. Keine Duplikate?
   3. Koordinaten plausibel?

Wenn alles okay → Sage "Freigabe!" für den Deploy.
```

## Nach "Freigabe!":

1. Build erstellen: `flutter build web --release`
2. Deploy vorbereiten
3. Nutzer kann mit `vercel --prod` deployen

---

## Wichtige Regeln

1. **Nur öffentliche Quellen** - Kein Login, kein Scraping von Paywalls
2. **robots.txt respektieren** - Wenn blockiert, Quelle überspringen
3. **Keine persönlichen Daten** - Nur Event-Infos, keine Veranstalter-Privatadressen
4. **Lieber weniger als falsch** - Bei Unsicherheit weglassen
5. **Quellen angeben** - Immer source_url speichern
```

---

## TEIL 3: Technische Umsetzung

### 3.1 Event-Datenstruktur in der App

```dart
// lib/src/features/events/domain/event_model.dart

@freezed
class MshEvent with _$MshEvent {
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
}

@freezed
class MshNotice with _$MshNotice {
  const factory MshNotice({
    required String id,
    required String type,
    required String title,
    String? description,
    String? affectedArea,
    DateTime? validFrom,
    DateTime? validUntil,
    required String severity,
    String? sourceUrl,
  }) = _MshNotice;
  
  factory MshNotice.fromJson(Map<String, dynamic> json) => 
      _$MshNoticeFromJson(json);
}
```

### 3.2 Events auf der Karte

```dart
// lib/src/features/events/presentation/event_map_layer.dart

class EventMapLayer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(currentEventsProvider);
    
    return eventsAsync.when(
      data: (events) => MarkerLayer(
        markers: events.map((event) => Marker(
          point: LatLng(event.latitude!, event.longitude!),
          width: 40,
          height: 40,
          child: _EventMarker(event: event),
        )).toList(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _EventMarker extends StatelessWidget {
  final MshEvent event;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEventDetails(context, event),
      child: Container(
        decoration: BoxDecoration(
          color: _getCategoryColor(event.category),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _getCategoryIcon(event.category),
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    return switch (category) {
      'konzert' => Colors.purple,
      'markt' => Colors.orange,
      'theater' => Colors.red,
      'sport' => Colors.green,
      'kinder' => Colors.pink,
      'fest' => Colors.amber,
      'führung' => Colors.blue,
      _ => Colors.grey,
    };
  }
  
  IconData _getCategoryIcon(String category) {
    return switch (category) {
      'konzert' => Icons.music_note,
      'markt' => Icons.storefront,
      'theater' => Icons.theater_comedy,
      'sport' => Icons.sports_soccer,
      'kinder' => Icons.child_care,
      'fest' => Icons.celebration,
      'führung' => Icons.directions_walk,
      _ => Icons.event,
    };
  }
}
```

### 3.3 Events-Liste Widget

```dart
// lib/src/features/events/presentation/widgets/upcoming_events.dart

class UpcomingEventsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(currentEventsProvider);
    
    return eventsAsync.when(
      data: (events) {
        // Gruppiere nach Datum
        final grouped = _groupByDate(events);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: MshColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Veranstaltungen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/events'),
                  child: const Text('Alle anzeigen'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Nächste 3 Tage
            ...grouped.entries.take(3).map((entry) => 
              _DateSection(date: entry.key, events: entry.value)
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
    );
  }
  
  Map<DateTime, List<MshEvent>> _groupByDate(List<MshEvent> events) {
    final map = <DateTime, List<MshEvent>>{};
    for (final event in events) {
      final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);
      map.putIfAbsent(dateOnly, () => []).add(event);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }
}

class _DateSection extends StatelessWidget {
  final DateTime date;
  final List<MshEvent> events;
  
  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final isTomorrow = _isTomorrow(date);
    
    final dateLabel = isToday 
        ? 'Heute' 
        : isTomorrow 
            ? 'Morgen' 
            : _formatDate(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isToday ? MshColors.primary : MshColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.white : MshColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...events.map((e) => _EventCard(event: e)),
        const SizedBox(height: 16),
      ],
    );
  }
}
```

### 3.4 Hinweis-Banner

```dart
// lib/src/features/notices/presentation/notice_banner.dart

class NoticeBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(activeNoticesProvider);
    
    return noticesAsync.when(
      data: (notices) {
        if (notices.isEmpty) return const SizedBox.shrink();
        
        // Zeige nur kritische/Warnungen
        final important = notices.where(
          (n) => n.severity == 'critical' || n.severity == 'warning'
        ).toList();
        
        if (important.isEmpty) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: important.first.severity == 'critical'
                ? MshColors.error.withOpacity(0.1)
                : MshColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: important.first.severity == 'critical'
                  ? MshColors.error
                  : MshColors.warning,
            ),
          ),
          child: Row(
            children: [
              Icon(
                important.first.severity == 'critical'
                    ? Icons.error
                    : Icons.warning_amber,
                color: important.first.severity == 'critical'
                    ? MshColors.error
                    : MshColors.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      important.first.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (important.first.description != null)
                      Text(
                        important.first.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: MshColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (important.length > 1)
                TextButton(
                  onPressed: () => _showAllNotices(context, notices),
                  child: Text('+${important.length - 1}'),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

---

## TEIL 4: Datei-Struktur

Nach dem Radar-Scan sieht das Projekt so aus:

```
msh_map/
├── lib/
│   └── src/
│       └── features/
│           ├── events/           ← NEU
│           │   ├── data/
│           │   ├── domain/
│           │   └── presentation/
│           └── notices/          ← NEU
│               ├── data/
│               ├── domain/
│               └── presentation/
│
├── data/                         ← NEU: Statische JSON-Daten
│   ├── events/
│   │   └── events_current.json
│   ├── notices/
│   │   └── notices_current.json
│   └── updates/
│       └── location_updates.json
│
├── reports/                      ← NEU: Radar-Reports
│   ├── RADAR_REPORT_2025-01-20.md
│   ├── RADAR_REPORT_2025-01-27.md
│   └── ...
│
└── prompts/
    └── MSH_RADAR_PROMPT.md       ← Der Haupt-Prompt
```

---

## TEIL 5: Wochen-Workflow

### Dein Ablauf (5 Minuten aktive Zeit)

```
SONNTAG ABEND / MONTAG MORGEN
─────────────────────────────

18:00  VS Code öffnen
       ↓
18:01  Claude Code starten
       Eingabe: "Führe MSH Radar Scan aus"
       oder: Paste den Prompt aus MSH_RADAR_PROMPT.md
       ↓
18:02  Claude beginnt zu arbeiten
       ↓
       ┌─────────────────────────────┐
       │  DU: Kaffee holen ☕        │
       │      E-Mails checken 📧     │
       │      Kurze Pause 🧘        │
       │      (20-30 Minuten)        │
       └─────────────────────────────┘
       ↓
18:30  Claude zeigt Zusammenfassung
       ↓
18:31  Du prüfst kurz:
       - Sehen die Events plausibel aus?
       - Keine Duplikate?
       - Keine falschen Daten?
       ↓
18:33  Du sagst: "Freigabe!"
       ↓
18:34  Claude macht Build fertig
       ↓
18:35  Du führst aus: vercel --prod
       ↓
18:36  ✅ FERTIG für diese Woche!
```

### Kalender-Erinnerung

```
📅 Sonntag, 18:00
   MSH Map Update
   - VS Code öffnen
   - Claude Radar starten
   - 30 Min warten
   - Freigabe + Deploy
```

---

## TEIL 6: Langfristige Automatisierung (Zukunft)

Wenn das manuelle System gut läuft, kannst du später automatisieren:

### Option A: GitHub Actions (Kostenlos)

```yaml
# .github/workflows/msh-radar.yml
name: MSH Radar Weekly

on:
  schedule:
    - cron: '0 6 * * 1'  # Jeden Montag 6 Uhr

jobs:
  radar:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Radar Script
        run: python scripts/msh_radar.py
      - name: Build Web
        run: flutter build web --release
      - name: Deploy to Vercel
        run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
```

### Option B: Lokaler Cron Job

```bash
# crontab -e
0 6 * * 1 cd /pfad/zu/msh_map && ./scripts/weekly_update.sh
```

### Option C: Vercel Cron Functions

```javascript
// api/cron/radar.js
export const config = {
  schedule: '@weekly'
};

export default async function handler(req, res) {
  // Radar-Logik hier
  res.status(200).json({ success: true });
}
```

**Aber:** Erstmal manuell starten - funktioniert super und du behältst Kontrolle!

---

## Fazit

Dein Plan ist perfekt:

| Aspekt | Bewertung |
|--------|-----------|
| **Aufwand** | ~5 Min aktiv, ~30 Min im Hintergrund |
| **Frequenz** | 1x pro Woche reicht völlig |
| **Kontrolle** | Du prüfst vor dem Deploy |
| **Flexibilität** | Kannst jederzeit Extra-Scan machen |
| **Skalierbar** | Später automatisierbar |

> **"Einmal die Woche Claude arbeiten lassen, kurz prüfen, deployen - fertig!"**
