# 25 - Community Features & Fog of War Map

## Übersicht

Zwei neue Features, die die MSH Map interaktiver und einzigartiger machen:

1. **"Fehlt etwas?"** - Community-Feedback mit Pin-Setzen
2. **Fog of War** - Nebeliger Rand außerhalb von MSH

---

## TEIL 1: "Fehlt etwas?" - Community Feedback

### Konzept

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🗺️  [Karte mit Pin-Modus aktiv]                          │
│                                                             │
│         ┌──────────────────────┐                           │
│         │  📍 Tippe auf die    │                           │
│         │  Karte um einen      │                           │
│         │  Ort zu markieren    │                           │
│         └──────────────────────┘                           │
│                                                             │
│              ╳ ← Nutzer tippt hier                         │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐  │
│   │  📍 Pin gesetzt bei:                                │  │
│   │  51.4723°N, 11.3045°E                               │  │
│   │  (Nähe Rosengarten, Sangerhausen)                   │  │
│   │                                                      │  │
│   │  Was fehlt hier?                                     │  │
│   │  ┌─────────────────────────────────────────────┐    │  │
│   │  │ Hier gibt es einen tollen Spielplatz...    │    │  │
│   │  └─────────────────────────────────────────────┘    │  │
│   │                                                      │  │
│   │  Kategorie: [Spielplatz ▼]                          │  │
│   │                                                      │  │
│   │  [  Abbrechen  ]     [  📧 Per E-Mail senden  ]     │  │
│   └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### User Flow

1. **Menü öffnen** → "Fehlt etwas?" antippen
2. **Pin-Modus aktiviert** → Overlay erscheint mit Anleitung
3. **Auf Karte tippen** → Pin wird gesetzt, Koordinaten erfasst
4. **Formular ausfüllt** → Beschreibung, Kategorie (optional)
5. **Absenden** → Öffnet E-Mail-App mit vorausgefüllten Daten

### Flutter Implementation

```dart
// lib/src/features/feedback/presentation/suggest_location_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SuggestLocationScreen extends StatefulWidget {
  const SuggestLocationScreen({super.key});

  @override
  State<SuggestLocationScreen> createState() => _SuggestLocationScreenState();
}

class _SuggestLocationScreenState extends State<SuggestLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();
  
  LatLng? _selectedLocation;
  String _selectedCategory = 'other';
  bool _isPinMode = true;
  
  // E-Mail Konfiguration
  static const String _feedbackEmail = 'feedback@kolan-systems.de';
  
  // Kategorien
  static const _categories = [
    ('playground', 'Spielplatz', Icons.toys),
    ('museum', 'Museum/Kultur', Icons.museum),
    ('nature', 'Natur/Wandern', Icons.park),
    ('pool', 'Schwimmbad/See', Icons.pool),
    ('gastro', 'Restaurant/Café', Icons.restaurant),
    ('event', 'Veranstaltungsort', Icons.event),
    ('other', 'Sonstiges', Icons.place),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ort vorschlagen'),
        actions: [
          if (_selectedLocation != null)
            TextButton.icon(
              onPressed: _sendFeedback,
              icon: const Icon(Icons.send),
              label: const Text('Senden'),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Karte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(51.4667, 11.3000), // MSH Zentrum
              initialZoom: 10,
              onTap: _isPinMode ? _onMapTap : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              
              // Gesetzter Pin
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const _AnimatedPin(),
                    ),
                  ],
                ),
            ],
          ),
          
          // Anleitung Overlay (wenn noch kein Pin)
          if (_selectedLocation == null)
            _buildInstructionOverlay(),
          
          // Formular (wenn Pin gesetzt)
          if (_selectedLocation != null)
            _buildFormSheet(),
        ],
      ),
    );
  }

  Widget _buildInstructionOverlay() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MshColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.touch_app, color: MshColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tippe auf die Karte',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Markiere den Ort, der auf der Karte fehlt',
                    style: TextStyle(
                      fontSize: 13,
                      color: MshColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Koordinaten Anzeige
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MshColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: MshColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Markierter Ort',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_selectedLocation!.latitude.toStringAsFixed(5)}°N, '
                            '${_selectedLocation!.longitude.toStringAsFixed(5)}°E',
                            style: TextStyle(
                              fontSize: 13,
                              color: MshColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_location_alt),
                      onPressed: () => setState(() => _selectedLocation = null),
                      tooltip: 'Neu setzen',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Kategorie Auswahl
              const Text(
                'Was für ein Ort ist das?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final (id, label, icon) = cat;
                  final isSelected = _selectedCategory == id;
                  return FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16),
                        const SizedBox(width: 4),
                        Text(label),
                      ],
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Beschreibung
              const Text(
                'Beschreibung',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Was gibt es hier? Warum sollte dieser Ort '
                           'auf die Karte?\n\nz.B. "Toller Spielplatz mit '
                           'Klettergerüst und Sandkasten"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Senden Button
              ElevatedButton.icon(
                onPressed: _sendFeedback,
                icon: const Icon(Icons.email),
                label: const Text('Per E-Mail senden'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Info Text
              Text(
                'Dein Vorschlag wird per E-Mail an uns gesendet. '
                'Wir prüfen ihn und fügen den Ort hinzu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: MshColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    
    // Karte zum Pin zentrieren
    _mapController.move(point, _mapController.camera.zoom);
  }

  Future<void> _sendFeedback() async {
    if (_selectedLocation == null) return;
    
    final lat = _selectedLocation!.latitude.toStringAsFixed(6);
    final lng = _selectedLocation!.longitude.toStringAsFixed(6);
    final category = _categories
        .firstWhere((c) => c.$1 == _selectedCategory).$2;
    final description = _descriptionController.text.trim();
    
    // Google Maps Link generieren
    final mapsLink = 'https://www.google.com/maps?q=$lat,$lng';
    
    // E-Mail Body
    final body = '''
Neuer Ort-Vorschlag für MSH Map
================================

📍 Koordinaten:
Latitude: $lat
Longitude: $lng

🗺️ Google Maps: $mapsLink

📂 Kategorie: $category

📝 Beschreibung:
${description.isNotEmpty ? description : '(Keine Beschreibung angegeben)'}

---
Gesendet über MSH Map App
''';

    final subject = Uri.encodeComponent('MSH Map - Neuer Ort: $category');
    final encodedBody = Uri.encodeComponent(body);
    
    final mailtoUri = Uri.parse(
      'mailto:$_feedbackEmail?subject=$subject&body=$encodedBody'
    );
    
    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-Mail App konnte nicht geöffnet werden'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

// Animierter Pin
class _AnimatedPin extends StatefulWidget {
  const _AnimatedPin();

  @override
  State<_AnimatedPin> createState() => _AnimatedPinState();
}

class _AnimatedPinState extends State<_AnimatedPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * _bounceAnimation.value),
          child: Icon(
            Icons.location_on,
            color: MshColors.primary,
            size: 50,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Menü-Integration

```dart
// Im Drawer/Sidebar:

ListTile(
  leading: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: MshColors.success.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.add_location_alt, color: MshColors.success),
  ),
  title: const Text('Fehlt etwas?'),
  subtitle: const Text('Ort vorschlagen'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.pop(context);
    context.push('/suggest-location');
  },
),
```

---

## TEIL 2: Fog of War - Nebliger Rand

### Konzept

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  ░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░ │
│  ░░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░░ │
│  ░░▒▒▓▓████████████████████████████████████████▓▓▒▒░░░░ │
│  ░░▒▓▓██   MANSFELD-SÜDHARZ (KLAR SICHTBAR)   ██▓▓▒░░░░ │
│  ░░▒▓▓██                                       ██▓▓▒░░░░ │
│  ░░▒▓▓██  Sangerhausen  ●                     ██▓▓▒░░░░ │
│  ░░▒▓▓██            Eisleben ●                ██▓▓▒░░░░ │
│  ░░▒▓▓██      ●  Hettstedt                    ██▓▓▒░░░░ │
│  ░░▒▓▓██                                       ██▓▓▒░░░░ │
│  ░░▒▓▓████████████████████████████████████████▓▓▒░░░░ │
│  ░░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░░ │
│  ░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░ │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                             │
│   Legende:                                                  │
│   ░ = Dichter Nebel (außerhalb MSH)                        │
│   ▒ = Übergangszone (Gradient)                             │
│   ▓ = Leichter Nebel                                       │
│   █ = Klar (MSH Kerngebiet)                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Technische Umsetzung

Es gibt mehrere Ansätze:

#### Option A: Polygon Overlay mit Loch (EMPFOHLEN)

```dart
// lib/src/shared/widgets/map/fog_of_war_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FogOfWarLayer extends StatelessWidget {
  const FogOfWarLayer({super.key});

  // MSH Grenzen (vereinfachtes Polygon)
  static const List<LatLng> _mshBorder = [
    // Norden
    LatLng(51.70, 11.05),
    LatLng(51.72, 11.20),
    LatLng(51.70, 11.40),
    LatLng(51.68, 11.55),
    LatLng(51.65, 11.70),
    // Osten
    LatLng(51.55, 11.75),
    LatLng(51.45, 11.72),
    LatLng(51.35, 11.65),
    // Süden
    LatLng(51.30, 11.50),
    LatLng(51.32, 11.30),
    LatLng(51.35, 11.10),
    // Westen
    LatLng(51.40, 10.95),
    LatLng(51.50, 10.90),
    LatLng(51.60, 10.95),
    // Zurück zum Start
    LatLng(51.70, 11.05),
  ];

  // Äußeres Rechteck (weit außerhalb)
  static const List<LatLng> _outerBounds = [
    LatLng(52.5, 9.5),   // NW
    LatLng(52.5, 13.0),  // NE
    LatLng(50.5, 13.0),  // SE
    LatLng(50.5, 9.5),   // SW
    LatLng(52.5, 9.5),   // Zurück
  ];

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: [
        // Hauptpolygon mit Loch
        Polygon(
          points: _outerBounds,
          holePointsList: [_mshBorder],
          color: const Color(0xDD1a1a2e), // Dunkler Nebel
          borderColor: Colors.transparent,
          borderStrokeWidth: 0,
        ),
      ],
    );
  }
}
```

#### Option B: Gradient Fog mit CustomPainter

```dart
// lib/src/shared/widgets/map/gradient_fog_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

class GradientFogLayer extends StatelessWidget {
  final MapCamera camera;
  
  const GradientFogLayer({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FogPainter(camera: camera),
      size: Size.infinite,
    );
  }
}

class _FogPainter extends CustomPainter {
  final MapCamera camera;
  
  // MSH Zentrum und Radius
  static const LatLng _center = LatLng(51.50, 11.35);
  static const double _innerRadius = 35000; // 35km - klarer Bereich
  static const double _outerRadius = 55000; // 55km - Nebel komplett
  
  _FogPainter({required this.camera});

  @override
  void paint(Canvas canvas, Size size) {
    // Bildschirm-Koordinaten des Zentrums
    final centerPoint = camera.latLngToScreenPoint(_center);
    
    // Radius in Pixeln (abhängig vom Zoom)
    final metersPerPixel = _getMetersPerPixel(camera);
    final innerRadiusPx = _innerRadius / metersPerPixel;
    final outerRadiusPx = _outerRadius / metersPerPixel;
    
    // Gradient Shader
    final gradient = ui.Gradient.radial(
      Offset(centerPoint.x, centerPoint.y),
      outerRadiusPx,
      [
        Colors.transparent,                    // Zentrum klar
        Colors.transparent,                    // Bis innerRadius klar
        const Color(0x40000000),              // Leichter Nebel
        const Color(0xAA1a1a2e),              // Dichter Nebel
        const Color(0xDD1a1a2e),              // Sehr dichter Nebel
      ],
      [
        0.0,
        innerRadiusPx / outerRadiusPx,  // ~64%
        (innerRadiusPx + 5000 / metersPerPixel) / outerRadiusPx,
        0.9,
        1.0,
      ],
    );
    
    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    
    // Zeichne über gesamten Bildschirm
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
    
    // Optionaler "Entdecken" Text am Rand
    _drawExploreHints(canvas, size, centerPoint, outerRadiusPx);
  }
  
  void _drawExploreHints(Canvas canvas, Size size, Point center, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '✨ Erkunde mehr...',
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // An mehreren Stellen am Rand anzeigen
    final angles = [0.0, 1.57, 3.14, 4.71]; // 0°, 90°, 180°, 270°
    for (final angle in angles) {
      final x = center.x + (radius * 0.85) * cos(angle);
      final y = center.y + (radius * 0.85) * sin(angle);
      
      // Nur zeichnen wenn im sichtbaren Bereich
      if (x > 0 && x < size.width && y > 0 && y < size.height) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle + 1.57); // Text nach außen ausrichten
        textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
        canvas.restore();
      }
    }
  }
  
  double _getMetersPerPixel(MapCamera camera) {
    // Vereinfachte Berechnung
    const earthCircumference = 40075016.686;
    return earthCircumference * cos(camera.center.latitudeInRad) / 
           pow(2, camera.zoom + 8);
  }

  @override
  bool shouldRepaint(_FogPainter oldDelegate) {
    return oldDelegate.camera != camera;
  }
}
```

#### Option C: SVG Mask (Einfachste Variante)

```dart
// Verwende ein vorgefertigtes SVG mit MSH-Form als Loch

class SvgFogLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlayImageLayer(
      overlayImages: [
        OverlayImage(
          bounds: LatLngBounds(
            LatLng(52.5, 9.5),   // NW
            LatLng(50.5, 13.0),  // SE
          ),
          imageProvider: const AssetImage('assets/fog_overlay.png'),
          opacity: 0.85,
        ),
      ],
    );
  }
}
```

### Komplette Integration

```dart
// lib/src/features/map/presentation/msh_map_view.dart

class MshMapView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFog = ref.watch(fogOfWarEnabledProvider);
    
    return FlutterMap(
      options: MapOptions(...),
      children: [
        // 1. Basis-Karte
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        
        // 2. Fog of War (vor den Markern!)
        if (showFog)
          const FogOfWarLayer(),
        
        // 3. Marker
        MarkerLayer(markers: _buildMarkers()),
        
        // 4. UI Overlays
        const MapControlsOverlay(),
      ],
    );
  }
}

// Toggle in Einstellungen
final fogOfWarEnabledProvider = StateProvider<bool>((ref) => true);
```

### Fog Anpassung bei Zoom

```dart
// Nebel wird bei hohem Zoom weniger sichtbar

class AdaptiveFogLayer extends StatelessWidget {
  final double zoom;
  
  @override
  Widget build(BuildContext context) {
    // Bei Zoom > 13 wird der Nebel transparenter
    final opacity = zoom > 13 
        ? max(0.0, 1.0 - (zoom - 13) * 0.15)
        : 1.0;
    
    if (opacity <= 0) return const SizedBox.shrink();
    
    return Opacity(
      opacity: opacity,
      child: const FogOfWarLayer(),
    );
  }
}
```

### "Entdecken" Teaser im Nebel

```dart
// Optional: Interaktive Teaser die zum Erkunden einladen

class FogTeaser extends StatelessWidget {
  final String text;
  final LatLng position;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## TEIL 3: Gemeinsame UX

### Willkommensbildschirm Update

```dart
// Erwähne beide Features im Welcome Screen

_FeatureItem(
  icon: Icons.add_location_alt,
  title: 'Gemeinsam wachsen',
  desc: 'Schlage fehlende Orte vor',
  highlight: true,
),

_FeatureItem(
  icon: Icons.explore,
  title: 'Entdecke MSH',
  desc: 'Deine Region, klar und deutlich',
),
```

### Navigation Update

```dart
// In app_router.dart:

GoRoute(
  path: '/suggest-location',
  builder: (context, state) => const SuggestLocationScreen(),
),
```

---

## TEIL 4: Implementierungs-Checkliste

### Fog of War
- [ ] MSH Grenz-Polygon definieren (genauer)
- [ ] FogOfWarLayer implementieren
- [ ] In Map-Widget integrieren
- [ ] Toggle in Einstellungen
- [ ] Zoom-Anpassung testen
- [ ] Performance prüfen

### Community Feedback
- [ ] SuggestLocationScreen implementieren
- [ ] Pin-Animation
- [ ] E-Mail Format testen
- [ ] Menü-Eintrag hinzufügen
- [ ] Route registrieren
- [ ] E-Mail Empfang testen

---

## E-Mail Format (Beispiel)

```
Betreff: MSH Map - Neuer Ort: Spielplatz

Neuer Ort-Vorschlag für MSH Map
================================

📍 Koordinaten:
Latitude: 51.472345
Longitude: 11.304521

🗺️ Google Maps: https://www.google.com/maps?q=51.472345,11.304521

📂 Kategorie: Spielplatz

📝 Beschreibung:
Hier gibt es einen tollen neuen Spielplatz mit Kletter-
gerüst, Schaukeln und einem großen Sandkasten. Sehr 
gepflegt und schattig durch alte Bäume.

---
Gesendet über MSH Map App
```
