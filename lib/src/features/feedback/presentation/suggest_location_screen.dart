import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/map_config.dart';

/// Screen für Community-Feedback: Nutzer können fehlende Orte vorschlagen
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
  final bool _isPinMode = true;

  // E-Mail Konfiguration
  static const String _feedbackEmail = 'feedback@kolan-systems.de';

  // Kategorien
  static const _categories = [
    ('playground', 'Spielplatz', Icons.child_care),
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
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_selectedLocation != null)
            TextButton.icon(
              onPressed: _sendFeedback,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text('Senden', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Karte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MapConfig.defaultCenter.toLatLng(),
              initialZoom: 10,
              onTap: _isPinMode ? _onMapTap : null,
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.tileUrlTemplate,
                userAgentPackageName: MapConfig.userAgent,
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
          if (_selectedLocation == null) _buildInstructionOverlay(),

          // Formular (wenn Pin gesetzt)
          if (_selectedLocation != null) _buildFormSheet(),
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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.touch_app, color: Colors.blueAccent),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tippe auf die Karte',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Markiere den Ort, der auf der Karte fehlt',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blueAccent),
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
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
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
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Info Text
              const Text(
                'Dein Vorschlag wird per E-Mail an uns gesendet. '
                'Wir prüfen ihn und fügen den Ort hinzu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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
    final category = _categories.firstWhere((c) => c.$1 == _selectedCategory).$2;
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
      'mailto:$_feedbackEmail?subject=$subject&body=$encodedBody',
    );

    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-Mail-App wird geöffnet...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-Mail App konnte nicht geöffnet werden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

/// Animierter Pin mit Bounce-Effekt
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
          child: const Icon(
            Icons.location_on,
            color: Colors.blueAccent,
            size: 50,
            shadows: [
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
