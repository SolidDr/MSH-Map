# Prompt 4: Karten-Features implementieren

## Probleme

| Feature | Status |
|---------|--------|
| Trackpad-Zoom | ❌ Funktioniert nicht |
| Click-to-Zoom Button | ❌ Fehlt |
| Karte ausnorden (Kompass) | ❌ Fehlt |

---

## A: Trackpad-Zoom (Pinch-to-Zoom / Scroll-Zoom)

### Problem
Zoom mit Trackpad (zwei-Finger-Geste oder Scroll) funktioniert nicht.

### Lösung für Flutter (flutter_map)

```dart
// In map_widget.dart oder map_screen.dart

FlutterMap(
  options: MapOptions(
    // Zoom-Einstellungen
    minZoom: 8.0,
    maxZoom: 18.0,
    
    // WICHTIG: InteractiveFlags aktivieren
    interactiveFlags: InteractiveFlag.all, // Alle Gesten aktivieren
    
    // Oder spezifisch:
    // interactiveFlags: InteractiveFlag.pinchZoom | 
    //                   InteractiveFlag.drag |
    //                   InteractiveFlag.doubleTapZoom |
    //                   InteractiveFlag.scrollWheelZoom,  // ← TRACKPAD!
    
    // Scroll-Wheel Zoom aktivieren
    enableScrollWheel: true,  // ← WICHTIG FÜR TRACKPAD!
    scrollWheelVelocity: 0.005,  // Geschwindigkeit anpassen
    
    // Multi-Touch für Pinch-Zoom
    enableMultiFingerGestureRace: true,
  ),
  children: [
    TileLayer(...),
    MarkerLayer(...),
  ],
)
```

### Für Web (falls flutter_map auf Web)

```dart
// Zusätzlich für Web-Unterstützung
import 'package:flutter/gestures.dart';

// In MaterialApp oder Scaffold
MaterialApp(
  scrollBehavior: MaterialScrollBehavior().copyWith(
    dragDevices: {
      PointerDeviceKind.mouse,
      PointerDeviceKind.touch,
      PointerDeviceKind.stylus,
      PointerDeviceKind.trackpad,  // ← TRACKPAD SUPPORT
    },
  ),
  ...
)
```

### Für Web mit JavaScript (falls Leaflet direkt)

```javascript
// Falls die App Leaflet im Web nutzt
const map = L.map('map', {
  scrollWheelZoom: true,        // Scroll-Zoom aktivieren
  touchZoom: true,              // Touch-Zoom aktivieren
  doubleClickZoom: true,        // Doppelklick-Zoom
  boxZoom: true,                // Box-Zoom (Shift+Drag)
  
  // Trackpad-spezifisch
  wheelPxPerZoomLevel: 120,     // Sensitivität anpassen
  wheelDebounceTime: 40,        // Debounce für smooth zoom
});
```

---

## B: Click-to-Zoom Buttons

### UI-Design

```
┌──────────────────────────────────────┐
│                                      │
│                              ┌───┐   │
│                              │ + │   │  ← Zoom In
│                              ├───┤   │
│                              │ - │   │  ← Zoom Out
│                              └───┘   │
│                                      │
│           KARTE                      │
│                                      │
│                              ┌───┐   │
│                              │ ◎ │   │  ← Standort
│                              └───┘   │
└──────────────────────────────────────┘
```

### Flutter Implementation

```dart
// widgets/zoom_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ZoomControls extends StatelessWidget {
  final MapController mapController;
  final double minZoom;
  final double maxZoom;
  
  const ZoomControls({
    Key? key,
    required this.mapController,
    this.minZoom = 8.0,
    this.maxZoom = 18.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 100,  // Unter der Suchleiste
      child: Column(
        children: [
          // Zoom In
          _ZoomButton(
            icon: Icons.add,
            tooltip: 'Vergrößern',
            onPressed: () => _zoom(1),
          ),
          const SizedBox(height: 8),
          // Zoom Out
          _ZoomButton(
            icon: Icons.remove,
            tooltip: 'Verkleinern',
            onPressed: () => _zoom(-1),
          ),
        ],
      ),
    );
  }
  
  void _zoom(int direction) {
    final currentZoom = mapController.camera.zoom;
    final newZoom = (currentZoom + direction).clamp(minZoom, maxZoom);
    
    mapController.move(
      mapController.camera.center,
      newZoom,
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  
  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
```

### In Map-Screen einbinden

```dart
// map_screen.dart

Stack(
  children: [
    FlutterMap(
      mapController: _mapController,
      options: MapOptions(...),
      children: [...],
    ),
    
    // Zoom Controls
    ZoomControls(mapController: _mapController),
    
    // Weitere UI-Elemente...
  ],
)
```

---

## C: Karte ausnorden (Kompass-Button)

### Funktionalität
- Button zeigt Kompass-Icon
- Wenn Karte gedreht ist: Icon zeigt Rotation an
- Bei Klick: Karte nach Norden ausrichten (Rotation = 0)

### Flutter Implementation

```dart
// widgets/compass_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math' as math;

class CompassButton extends StatefulWidget {
  final MapController mapController;
  
  const CompassButton({Key? key, required this.mapController}) : super(key: key);
  
  @override
  State<CompassButton> createState() => _CompassButtonState();
}

class _CompassButtonState extends State<CompassButton> {
  double _rotation = 0;
  
  @override
  void initState() {
    super.initState();
    widget.mapController.mapEventStream.listen((event) {
      if (event is MapEventRotate) {
        setState(() {
          _rotation = event.camera.rotation;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Nur anzeigen wenn Karte gedreht ist
    if (_rotation.abs() < 0.01) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      right: 16,
      top: 200,  // Unter Zoom-Buttons
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        child: InkWell(
          onTap: _resetNorth,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -_rotation * (math.pi / 180),
              child: Icon(
                Icons.navigation,
                size: 24,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _resetNorth() {
    widget.mapController.rotate(0);
  }
}
```

### Alternative: Immer sichtbarer Kompass

```dart
// Immer sichtbar, aber nur aktiv wenn gedreht
class AlwaysVisibleCompass extends StatelessWidget {
  final MapController mapController;
  final double rotation;
  
  const AlwaysVisibleCompass({
    Key? key,
    required this.mapController,
    required this.rotation,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isRotated = rotation.abs() > 0.01;
    
    return Positioned(
      right: 16,
      top: 200,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: isRotated ? Colors.white : Colors.grey.shade200,
        child: InkWell(
          onTap: isRotated ? () => mapController.rotate(0) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -rotation * (math.pi / 180),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Norden-Pfeil (rot)
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Süden-Pfeil (weiß/grau)
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Mittelpunkt
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Komplettes Karten-Control-Widget

```dart
// widgets/map_controls.dart

class MapControls extends StatelessWidget {
  final MapController mapController;
  final double currentZoom;
  final double currentRotation;
  final VoidCallback? onLocationPressed;
  
  const MapControls({
    Key? key,
    required this.mapController,
    required this.currentZoom,
    required this.currentRotation,
    this.onLocationPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          // Kompass (nur wenn gedreht)
          if (currentRotation.abs() > 0.01) ...[
            _ControlButton(
              icon: Transform.rotate(
                angle: -currentRotation * (math.pi / 180),
                child: const Icon(Icons.navigation, color: Colors.red),
              ),
              tooltip: 'Nach Norden ausrichten',
              onPressed: () => mapController.rotate(0),
            ),
            const SizedBox(height: 8),
          ],
          
          // Zoom In
          _ControlButton(
            icon: const Icon(Icons.add),
            tooltip: 'Vergrößern',
            onPressed: () => _zoom(1),
          ),
          const SizedBox(height: 8),
          
          // Zoom Out
          _ControlButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Verkleinern',
            onPressed: () => _zoom(-1),
          ),
          const SizedBox(height: 16),
          
          // Standort
          if (onLocationPressed != null)
            _ControlButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Mein Standort',
              onPressed: onLocationPressed!,
              highlight: true,
            ),
        ],
      ),
    );
  }
  
  void _zoom(int direction) {
    final newZoom = (currentZoom + direction).clamp(8.0, 18.0);
    mapController.move(mapController.camera.center, newZoom);
  }
}

class _ControlButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool highlight;
  
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.highlight = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: highlight ? Theme.of(context).primaryColor : Colors.white,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: IconTheme(
              data: IconThemeData(
                color: highlight ? Colors.white : Colors.black87,
                size: 24,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Checkliste

```
TRACKPAD-ZOOM:
[ ] InteractiveFlag.scrollWheelZoom aktiviert
[ ] enableScrollWheel: true gesetzt
[ ] scrollWheelVelocity angepasst
[ ] Auf Desktop getestet
[ ] Auf Laptop mit Trackpad getestet

ZOOM-BUTTONS:
[ ] ZoomControls Widget erstellt
[ ] Zoom In funktioniert
[ ] Zoom Out funktioniert
[ ] Buttons sichtbar und erreichbar
[ ] Touch-Target min. 44x44px

KOMPASS:
[ ] CompassButton Widget erstellt
[ ] Rotation wird korrekt dargestellt
[ ] Klick richtet nach Norden aus
[ ] Button erscheint nur wenn gedreht
```

---

## Deliverables

1. **map_controls.dart** - Komplettes Control-Widget
2. **Aktualisierte MapOptions** mit Zoom-Einstellungen
3. **Test-Bestätigung:** Alle Features funktionieren
