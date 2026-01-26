# 22 - Regionale Insights & Daten-Visualisierung

## Vision: Von Daten zu Mehrwert

Die MSH Map wird mehr als nur eine Karte mit Punkten. Sie wird ein **regionales Dashboard**, das:

1. **Familien** hilft, die besten Ausflugsziele zu finden
2. **Gemeinden** zeigt, wo Infrastruktur fehlt
3. **Unternehmer** Standort-Entscheidungen erleichtert
4. **Tourismus** Potenziale sichtbar macht
5. **Bürger** ihre Region besser verstehen lässt

---

## TEIL 1: Datenbasierte Features für Nutzer

### 1.1 "Perfekter Familientag" - Routenplaner

```
┌─────────────────────────────────────────┐
│  🎯 Dein perfekter Familientag         │
├─────────────────────────────────────────┤
│  Startpunkt: [Sangerhausen      ▼]     │
│  Kinder-Alter: [3-6 Jahre       ▼]     │
│  Verfügbare Zeit: [Halber Tag   ▼]     │
│  Interessen: [🏰 ☑️] [🏊 ☑️] [🎨 ☐]   │
│                                         │
│  [  Route berechnen  ]                  │
└─────────────────────────────────────────┘

Ergebnis:
┌─────────────────────────────────────────┐
│  Vorgeschlagene Route (4h, 35km)       │
├─────────────────────────────────────────┤
│  09:00  🏰 Schloss Mansfeld            │
│         ↓ 15 Min Fahrt                  │
│  10:30  🌳 Spielplatz Rosengarten      │
│         ↓ 10 Min Fahrt                  │
│  12:00  🍽️ Ratskeller (Mittagessen)    │
│         ↓ 5 Min Fahrt                   │
│  14:00  🏊 Erlebnisbad Sangerhausen    │
│                                         │
│  [Zur Navigation] [Route teilen]        │
└─────────────────────────────────────────┘
```

**Daten die wir nutzen:**
- Öffnungszeiten für zeitliche Planung
- Altersempfehlungen für Filterung
- Koordinaten für Routenberechnung
- Kategorie-Mix für Abwechslung

---

### 1.2 "Was ist los?" - Live-Aktivitäts-Heatmap

```
┌─────────────────────────────────────────┐
│  Heute in MSH                          │
├─────────────────────────────────────────┤
│                                         │
│    ░░░▓▓███░░░░░░░░▓▓░░░              │
│    ░░▓████▓░░░░░░░▓██▓░░              │
│    ░▓█████░░░░░░░░░███░░   ← Heatmap  │
│    ░░▓███░░░░░░░░░░▓█░░░              │
│    ░░░░░░░░░░░░░░░░░░░░░              │
│                                         │
│  🔥 Hotspots heute:                    │
│  • Europa-Rosarium (Rosenfest)         │
│  • Süßer See (Badewetter!)             │
│  • Kyffhäuser (Wandersaison)           │
└─────────────────────────────────────────┘
```

**Daten die wir nutzen:**
- Saisonale Relevanz (Freibad im Sommer, Hallenbad im Winter)
- Events und Veranstaltungen
- Wetter-API Integration
- Historische Besuchsdaten (anonymisiert)

---

### 1.3 "Entdecke Verborgenes" - Hidden Gems Score

Orte die weniger bekannt, aber hochwertig sind:

```
┌─────────────────────────────────────────┐
│  💎 Geheimtipps in deiner Nähe         │
├─────────────────────────────────────────┤
│                                         │
│  ⭐⭐⭐⭐⭐ Wippertalsperre              │
│  "Unser Lieblings-Badesee!"            │
│  Nur 12km · Wenig bekannt · Top bewertet│
│                                         │
│  ⭐⭐⭐⭐☆ Numburg Aussichtspunkt        │
│  "Atemberaubender Blick!"              │
│  8km · Geheimtipp · Kostenlos          │
│                                         │
└─────────────────────────────────────────┘
```

**Hidden Gem Score berechnet aus:**
- Hohe Bewertung ABER niedrige View-Counts
- Nicht in Top-10 der Kategorie
- Positive Beschreibungen
- Abseits der Hauptrouten

---

### 1.4 "Vergleiche Orte" - Side-by-Side

```
┌───────────────────┬───────────────────┐
│  Süßer See        │  Wippertalsperre  │
├───────────────────┼───────────────────┤
│  ⭐ 4.2 (89 Bew.) │  ⭐ 4.6 (23 Bew.) │
│  📍 15km entfernt │  📍 22km entfernt │
│  💰 Kostenlos     │  💰 Kostenlos     │
│  👶 Alle Alter    │  👶 6+ Jahre      │
│  🅿️ Ja           │  🅿️ Begrenzt     │
│  🍽️ Kiosk        │  🍽️ Nein         │
│  ♿ Teilweise     │  ♿ Nein          │
│                   │                   │
│  [Auswählen]      │  [Auswählen]      │
└───────────────────┴───────────────────┘
```

---

## TEIL 2: Regionale Insights (Dashboard)

### 2.1 "MSH in Zahlen" - Öffentliches Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  📊 Mansfeld-Südharz in Zahlen                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │   147   │  │    23   │  │    12   │  │    45   │       │
│  │  Orte   │  │Spielpl. │  │ Museen  │  │ Gastro  │       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
│                                                             │
│  Familienfreundlichkeit nach Stadt:                        │
│  ┌──────────────────────────────────────────┐              │
│  │ Sangerhausen    ████████████░░░ 78%     │              │
│  │ Eisleben        ██████████░░░░░ 65%     │              │
│  │ Hettstedt       ██████░░░░░░░░░ 42%     │              │
│  │ Mansfeld        ████████░░░░░░░ 55%     │              │
│  └──────────────────────────────────────────┘              │
│                                                             │
│  Saisonale Aktivität:                                      │
│  [Frühling ▁▃█▅▂ Sommer ▂▅███▅ Herbst ▃▅█▃▂ Winter]       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.2 "Infrastruktur-Gaps" - Für Gemeinden/Planer

```
┌─────────────────────────────────────────────────────────────┐
│  🔍 Infrastruktur-Analyse                    [Für Planer]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ⚠️ Identifizierte Lücken:                                 │
│                                                             │
│  🔴 KRITISCH                                               │
│  ├── Hettstedt: Kein Spielplatz im Zentrum (>2km)         │
│  └── Südharz: Kein Hallenbad (nächstes: 25km)             │
│                                                             │
│  🟡 VERBESSERUNGSPOTENZIAL                                 │
│  ├── Allstedt: Nur 1 Restaurant für 8.000 EW              │
│  ├── Mansfeld: Kein barrierefreies Museum                 │
│  └── Region: Wenig Indoor-Angebote für Regentage          │
│                                                             │
│  🟢 GUT ABGEDECKT                                          │
│  ├── Sangerhausen: Spielplätze (4.2 pro 10k EW)           │
│  └── Eisleben: Kulturangebot (UNESCO, Museen)             │
│                                                             │
│  [Export als PDF]  [Daten herunterladen]                   │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.3 "Tourismus-Potenzial" - Für Wirtschaftsförderung

```
┌─────────────────────────────────────────────────────────────┐
│  📈 Tourismus-Potenzial MSH                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Stärken (ausbauen):                                       │
│  ████████████████ Luther-Tourismus (UNESCO)                │
│  ██████████████░░ Bergbau-Geschichte                       │
│  ████████████░░░░ Natur/Wandern                            │
│  ██████████░░░░░░ Burgen & Schlösser                       │
│                                                             │
│  Schwächen (verbessern):                                   │
│  ████░░░░░░░░░░░░ Gastronomie-Vielfalt                     │
│  ██░░░░░░░░░░░░░░ Digitale Sichtbarkeit                    │
│  ███░░░░░░░░░░░░░ Barrierefreiheit                         │
│                                                             │
│  Ungenutzte Potenziale:                                    │
│  • Rosarium → Mehr überregionale Vermarktung               │
│  • Kyffhäuser → Kopplung mit Barbarossa-Sage               │
│  • Bergbau → Erlebnistouren für Familien                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## TEIL 3: Visualisierungs-Komponenten

### 3.1 Interaktive Karten-Layer

```dart
// lib/src/shared/widgets/map_layers/

enum MapLayer {
  standard,           // Normale POI-Ansicht
  heatmap,           // Aktivitäts-Heatmap
  coverage,          // Abdeckungs-Overlay
  familyScore,       // Familienfreundlichkeit
  accessibility,     // Barrierefreiheit
  seasonal,          // Saisonale Relevanz
}

class LayerSwitcher extends StatelessWidget {
  // Erlaubt Wechsel zwischen Ansichten
}
```

**Layer-Beschreibung:**

| Layer | Visualisierung | Nutzen |
|-------|----------------|--------|
| **Heatmap** | Farbverlauf (Rot=viel, Blau=wenig) | Wo ist was los? |
| **Coverage** | Grüne/Rote Zonen | Wo fehlt Infrastruktur? |
| **Family Score** | Emoji-Overlay (😊/😐/😢) | Familienfreundlichste Gebiete |
| **Accessibility** | ♿-Icons, Graustufen | Barrierefreie Orte |
| **Seasonal** | Sonne/Schneeflocke Icons | Was passt zur Jahreszeit? |

---

### 3.2 Dashboard-Widgets

```dart
// Kompakte Info-Karten für Dashboard

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend; // "+5%" oder "-2%"
}

class ProgressBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 - 1.0
  final Color color;
}

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final String label;
}

class ComparisonCard extends StatelessWidget {
  final Location location1;
  final Location location2;
}
```

---

### 3.3 Insight-Cards

```dart
// lib/src/features/insights/widgets/insight_card.dart

class InsightCard extends StatelessWidget {
  final InsightType type;
  final String title;
  final String description;
  final Widget? visualization;
  final VoidCallback? onAction;
  
  // Typen: gap, recommendation, trend, achievement
}

// Beispiel-Verwendung:
InsightCard(
  type: InsightType.gap,
  title: "Spielplatz-Wüste erkannt",
  description: "In Hettstedt-Zentrum gibt es keinen Spielplatz "
               "im Umkreis von 2km. 3.500 Kinder sind betroffen.",
  visualization: MiniMap(
    center: LatLng(51.65, 11.50),
    radius: 2000,
    highlightGap: true,
  ),
  onAction: () => showGapDetails(),
)
```

---

## TEIL 4: Daten-Pipeline

### 4.1 DeepScan → Firestore → App

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  DeepScan   │────▶│  Firestore  │────▶│   MSH Map   │
│  (Python)   │     │  (Backend)  │     │  (Flutter)  │
└─────────────┘     └─────────────┘     └─────────────┘
      │                    │                    │
      ▼                    ▼                    ▼
  Rohdaten            Strukturiert         Visualisiert
  + Analyse           + Aggregiert         + Interaktiv
```

### 4.2 Firestore Collections

```
firestore/
├── locations/              # Einzelne Orte
│   └── {id}/
│       ├── ...basisfelder
│       └── computed/       # Berechnete Werte
│           ├── popularityScore
│           ├── familyScore
│           └── seasonalRelevance
│
├── analytics/              # Aggregierte Analysen
│   ├── region_stats/
│   │   └── {city}/
│   │       ├── locationCount
│   │       ├── categoryDistribution
│   │       └── coverageScore
│   │
│   ├── gaps/
│   │   └── {gapId}/
│   │       ├── type
│   │       ├── location
│   │       ├── severity
│   │       └── affectedPopulation
│   │
│   └── insights/
│       └── {insightId}/
│           ├── type
│           ├── title
│           ├── description
│           └── createdAt
│
├── trends/                 # Zeitliche Entwicklung
│   └── {metric}/
│       └── {date}/
│           └── value
│
└── user_contributions/     # Community-Beiträge
    └── {contributionId}/
        ├── type (correction, suggestion, photo)
        ├── locationId
        └── status (pending, approved, rejected)
```

### 4.3 Cloud Functions für Aggregation

```javascript
// functions/src/analytics.ts

// Täglich: Statistiken aktualisieren
exports.updateDailyStats = functions.pubsub
  .schedule('0 3 * * *')  // 3 Uhr nachts
  .onRun(async () => {
    await updateCategoryDistribution();
    await updateCoverageScores();
    await detectNewGaps();
    await generateInsights();
  });

// Bei View: Popularity aktualisieren
exports.onLocationView = functions.firestore
  .document('locations/{locationId}')
  .onUpdate(async (change, context) => {
    await updatePopularityScore(context.params.locationId);
  });
```

---

## TEIL 5: Implementierungs-Plan

### Phase 1: Basis-Visualisierung (1 Woche)
- [ ] Locations aus Firestore laden
- [ ] Kategorie-Farben auf Karte
- [ ] Filter nach Kategorie
- [ ] Basis-Statistiken anzeigen

### Phase 2: Dashboard (1-2 Wochen)
- [ ] "MSH in Zahlen" Widget
- [ ] Stadt-Vergleich
- [ ] Kategorie-Verteilung Chart

### Phase 3: Smart Features (2 Wochen)
- [ ] Familientag-Routenplaner
- [ ] Hidden Gems Algorithmus
- [ ] Saisonale Empfehlungen

### Phase 4: Insights (1-2 Wochen)
- [ ] Gap-Visualisierung
- [ ] Insight-Cards
- [ ] Export für Gemeinden

### Phase 5: Community (ongoing)
- [ ] "Ort vorschlagen" Flow
- [ ] Korrektur-Meldungen
- [ ] Foto-Beiträge

---

## TEIL 6: Konkrete Mehrwerte

### Für Familien
| Feature | Mehrwert |
|---------|----------|
| Routenplaner | Kein Planungsstress mehr |
| Altersfilter | Passende Aktivitäten finden |
| Hidden Gems | Neue Orte entdecken |
| Wetter-Integration | "Heute ist Hallenbad-Tag" |

### Für Gemeinden
| Feature | Mehrwert |
|---------|----------|
| Gap-Analyse | Wissen wo investieren |
| Vergleich mit Nachbarn | Benchmark |
| Trend-Daten | Entwicklung verfolgen |
| Export | Für Präsentationen |

### Für Tourismus
| Feature | Mehrwert |
|---------|----------|
| Potenzial-Analyse | Marketing-Fokus |
| Saisonale Daten | Kampagnen-Timing |
| Stärken/Schwächen | Strategische Planung |

### Für Unternehmer
| Feature | Mehrwert |
|---------|----------|
| Gastronomie-Gaps | Wo fehlt ein Restaurant? |
| Frequenz-Daten | Standort-Entscheidung |
| Konkurrenz-Analyse | Marktüberblick |

---

## Fazit

Die MSH Map wird von einer **Karten-App** zu einer **regionalen Datenplattform**:

1. **Sichtbar machen** was die Region bietet
2. **Lücken aufzeigen** wo Verbesserung nötig ist
3. **Entscheidungen unterstützen** für Familien, Gemeinden, Unternehmer
4. **Vernetzung fördern** durch geteiltes Wissen
5. **Stolz wecken** auf das Potenzial der Region

> "MSH Map: Die Region verstehen. Die Region verbessern."
