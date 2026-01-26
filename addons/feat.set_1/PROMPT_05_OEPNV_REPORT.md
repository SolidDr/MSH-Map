# PROMPT 5: ÖPNV-Links & Problem-Melden

## Kontext

Du arbeitest am MSH Map Projekt.
Feature-Flags, Altersfilter, Wetter und Events sind bereits implementiert.
`FeatureFlags.enablePublicTransport` und `FeatureFlags.enableReportIssue` sind `true`.

## Deine Aufgabe

Implementiere:
1. ÖPNV-Link bei jedem Ort (Verbindung zu INSA)
2. "Problem melden" Feature (anonym per E-Mail)

---

# TEIL 1: ÖPNV-Links

## Schritt 1.1: ÖPNV-Button erstellen

Erstelle `lib/src/shared/widgets/public_transport_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/feature_flags.dart';

class PublicTransportButton extends StatelessWidget {
  final String destinationName;
  final String? city;
  
  const PublicTransportButton({
    super.key,
    required this.destinationName,
    this.city,
  });

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlags.enablePublicTransport) {
      return const SizedBox.shrink();
    }
    
    return OutlinedButton.icon(
      onPressed: _openINSA,
      icon: const Icon(Icons.directions_bus, size: 18),
      label: const Text('ÖPNV-Verbindung'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue.shade700,
        side: BorderSide(color: Colors.blue.shade200),
      ),
    );
  }
  
  void _openINSA() {
    // INSA = Nahverkehr Sachsen-Anhalt
    // URL mit Ziel vorausfüllen
    final destination = city != null 
        ? '$destinationName, $city' 
        : destinationName;
    
    final encodedDestination = Uri.encodeComponent(destination);
    
    // INSA Fahrplanauskunft URL
    // Alternativ: NASA (Nahverkehrsservice Sachsen-Anhalt)
    final url = 'https://www.insa.de/fahrplanauskunft'
        '?ziel=$encodedDestination';
    
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// Kompakter Icon-Button für Listen
class PublicTransportIconButton extends StatelessWidget {
  final String destinationName;
  final String? city;
  
  const PublicTransportIconButton({
    super.key,
    required this.destinationName,
    this.city,
  });

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlags.enablePublicTransport) {
      return const SizedBox.shrink();
    }
    
    return IconButton(
      onPressed: _openINSA,
      icon: const Icon(Icons.directions_bus),
      tooltip: 'ÖPNV-Verbindung',
      color: Colors.blue.shade700,
    );
  }
  
  void _openINSA() {
    final destination = city != null 
        ? '$destinationName, $city' 
        : destinationName;
    final encodedDestination = Uri.encodeComponent(destination);
    final url = 'https://www.insa.de/fahrplanauskunft?ziel=$encodedDestination';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
```

## Schritt 1.2: In Location-Details einbauen

Im Location-Detail-Sheet (wo Ort-Infos angezeigt werden):

```dart
// Bei den Buttons am Ende des Detail-Sheets:
Row(
  children: [
    // Route (Google Maps / OSM)
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _openMaps(location),
        icon: const Icon(Icons.directions),
        label: const Text('Route'),
      ),
    ),
    const SizedBox(width: 8),
    
    // ÖPNV (NEU)
    if (FeatureFlags.enablePublicTransport)
      Expanded(
        child: PublicTransportButton(
          destinationName: location.name,
          city: location.city,
        ),
      ),
  ],
)
```

---

# TEIL 2: Problem-Melden Feature

## Schritt 2.1: Issue-Types definieren

Erstelle `lib/src/features/feedback/domain/issue_type.dart`:

```dart
import 'package:flutter/material.dart';

enum IssueType {
  danger(
    'danger',
    'Gefahr / Sicherheit',
    'Kaputte Spielgeräte, Glasscherben, gefährliche Stellen',
    Icons.warning,
    Colors.red,
  ),
  closed(
    'closed',
    'Geschlossen / Baustelle',
    'Ort ist geschlossen oder nicht zugänglich',
    Icons.construction,
    Colors.orange,
  ),
  removed(
    'removed',
    'Existiert nicht mehr',
    'Der Ort existiert nicht mehr',
    Icons.delete_forever,
    Colors.grey,
  ),
  wrongLocation(
    'wrong_location',
    'Falsche Position',
    'Der Marker ist an der falschen Stelle',
    Icons.location_off,
    Colors.blue,
  ),
  wrongInfo(
    'wrong_info',
    'Falsche Informationen',
    'Name, Beschreibung oder andere Angaben sind falsch',
    Icons.edit,
    Colors.purple,
  ),
  other(
    'other',
    'Sonstiges',
    'Anderes Problem',
    Icons.help_outline,
    Colors.teal,
  );

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const IssueType(this.id, this.label, this.description, this.icon, this.color);
}
```

## Schritt 2.2: Report-Sheet erstellen

Erstelle `lib/src/features/feedback/presentation/report_issue_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/issue_type.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/config/app_config.dart';

class ReportIssueSheet extends StatefulWidget {
  final String locationId;
  final String locationName;
  final double? latitude;
  final double? longitude;

  const ReportIssueSheet({
    super.key,
    required this.locationId,
    required this.locationName,
    this.latitude,
    this.longitude,
  });

  static void show(
    BuildContext context, {
    required String locationId,
    required String locationName,
    double? latitude,
    double? longitude,
  }) {
    if (!FeatureFlags.enableReportIssue) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReportIssueSheet(
        locationId: locationId,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  IssueType? _selectedType;
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
              
              // Header
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Problem melden',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Ort-Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.locationName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Problem-Typ Auswahl
              Text(
                'Was ist das Problem?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              // Issue-Type Buttons
              ...IssueType.values.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _IssueTypeButton(
                  type: type,
                  isSelected: _selectedType == type,
                  onTap: () => setState(() => _selectedType = type),
                ),
              )),
              
              const SizedBox(height: 16),
              
              // Beschreibung
              Text(
                'Beschreibung (optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Beschreibe das Problem genauer...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Senden Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedType != null ? _sendReport : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Per E-Mail melden'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deine Meldung ist anonym. Wir prüfen sie und aktualisieren die Karte.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendReport() {
    if (_selectedType == null) return;
    
    final subject = 'MSH Map Problem: ${_selectedType!.label}';
    
    final coordinates = widget.latitude != null && widget.longitude != null
        ? 'Koordinaten: ${widget.latitude}, ${widget.longitude}\n'
          'Google Maps: https://www.google.com/maps?q=${widget.latitude},${widget.longitude}'
        : 'Koordinaten: nicht verfügbar';
    
    final body = '''
Problem-Meldung für MSH Map
===========================

📍 Ort: ${widget.locationName}
🆔 ID: ${widget.locationId}
$coordinates

⚠️ Problem-Typ: ${_selectedType!.label}
📝 Beschreibung: ${_selectedType!.description}

💬 Zusätzliche Infos:
${_descriptionController.text.isNotEmpty ? _descriptionController.text : '(Keine zusätzlichen Infos)'}

---
Diese Meldung wurde anonym über die MSH Map App gesendet.
''';

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: AppConfig.feedbackEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    
    launchUrl(mailtoUri);
    Navigator.pop(context);
    
    // Feedback an User
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Danke für deine Meldung!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class _IssueTypeButton extends StatelessWidget {
  final IssueType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueTypeButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? type.color.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? type.color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(type.icon, color: type.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      type.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: type.color),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Schritt 2.3: Button in Location-Details einbauen

Im Location-Detail-Sheet, füge einen "Problem melden" Button hinzu:

```dart
// Am Ende des Detail-Sheets:
const Divider(height: 32),

// Problem melden Button
if (FeatureFlags.enableReportIssue)
  TextButton.icon(
    onPressed: () {
      Navigator.pop(context); // Sheet schließen
      ReportIssueSheet.show(
        context,
        locationId: location.id,
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
      );
    },
    icon: Icon(Icons.flag, color: Colors.grey.shade600, size: 18),
    label: Text(
      'Problem melden',
      style: TextStyle(color: Colors.grey.shade600),
    ),
  ),
```

## Schritt 2.4: App-Config für E-Mail

Stelle sicher dass in `app_config.dart`:

```dart
class AppConfig {
  // ...
  static const String feedbackEmail = 'feedback@kolan-systems.de';
  // ...
}
```

## Schritt 3: url_launcher hinzufügen

In `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.0
```

Dann: `flutter pub get`

## Abschluss

Nach Fertigstellung:
- [ ] PublicTransportButton erstellt
- [ ] In Location-Details eingebaut
- [ ] IssueType Enum mit 6 Problem-Typen
- [ ] ReportIssueSheet mit Problem-Auswahl
- [ ] E-Mail wird korrekt generiert
- [ ] Anonyme Meldung (keine Nutzer-ID)
- [ ] Feature-Flags integriert
- [ ] url_launcher hinzugefügt

Teste:
1. Ort-Details öffnen → ÖPNV-Button sichtbar
2. ÖPNV-Button klicken → INSA öffnet sich
3. "Problem melden" klicken → Sheet öffnet
4. Problem-Typ auswählen → Absenden
5. E-Mail-App öffnet mit vorausgefüllten Daten

Zeige mir eine Zusammenfassung.
