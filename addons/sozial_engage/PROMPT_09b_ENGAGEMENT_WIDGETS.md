# PROMPT 09b: Soziales Engagement Feature - Teil 2 (Widgets & UI)

## Fortsetzung von PROMPT 09a

Dieser Teil implementiert die UI-Komponenten für das Engagement-Feature.

---

## TEIL 3: Engagement-Marker (Pulsierend)

### 3.1 Pulsierender Engagement-Marker

Erstelle `lib/src/features/engagement/presentation/engagement_marker.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/config/feature_flags.dart';
import '../domain/engagement_model.dart';

/// Spezieller Marker für Engagement-Orte
/// Mit goldenem Rahmen und optional pulsierendem Effekt bei Dringlichkeit
class EngagementMarker extends StatefulWidget {
  final EngagementType type;
  final UrgencyLevel urgency;
  final bool isSelected;
  final int? adoptableCount;
  final VoidCallback? onTap;
  final double size;

  const EngagementMarker({
    super.key,
    required this.type,
    this.urgency = UrgencyLevel.normal,
    this.isSelected = false,
    this.adoptableCount,
    this.onTap,
    this.size = 48,
  });

  @override
  State<EngagementMarker> createState() => _EngagementMarkerState();
}

class _EngagementMarkerState extends State<EngagementMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Pulsieren bei dringenden Markern
    if (_shouldPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  bool get _shouldPulse =>
      FeatureFlags.enablePulsingMarkers &&
      (widget.urgency == UrgencyLevel.urgent ||
          widget.urgency == UrgencyLevel.critical);

  @override
  void didUpdateWidget(EngagementMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = MshColors.getEngagementColor(widget.type.id);
    final borderRadius = BorderRadius.circular(widget.size * 0.25);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _shouldPulse ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Äußerer goldener Glow (für Engagement)
            Container(
              width: widget.size + 8,
              height: widget.size + 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular((widget.size + 8) * 0.25),
                boxShadow: [
                  BoxShadow(
                    color: MshColors.engagementGold.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  if (_shouldPulse)
                    BoxShadow(
                      color: widget.urgency.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                ],
              ),
            ),

            // Hauptmarker
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: MshColors.engagementGold,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.type.emoji,
                    style: TextStyle(fontSize: widget.size * 0.45),
                  ),
                ),
              ),
            ),

            // Herz-Badge oben links
            Positioned(
              top: -2,
              left: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: MshColors.engagementHeart,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('❤️', style: TextStyle(fontSize: 10)),
                ),
              ),
            ),

            // Dringlichkeits-Badge oben rechts
            if (widget.urgency != UrgencyLevel.normal)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.urgency.color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    widget.urgency == UrgencyLevel.critical ? '!' : '⚡',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Tier-Anzahl Badge unten rechts
            if (widget.adoptableCount != null && widget.adoptableCount! > 0)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: MshColors.forest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.adoptableCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Zeiger unten
            Positioned(
              bottom: -6,
              left: (widget.size + 8 - 12) / 2,
              child: CustomPaint(
                size: const Size(12, 6),
                painter: _TrianglePainter(
                  color: typeColor,
                  borderColor: MshColors.engagementGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## TEIL 4: Tier-Karte mit Bild

### 4.1 Adoptable Animal Card

Erstelle `lib/src/features/engagement/presentation/adoptable_animal_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../domain/engagement_model.dart';
import '../data/engagement_repository.dart';

/// Karte für ein adoptierbares Tier
/// Mit Bild, Details und Dringlichkeits-Anzeige
class AdoptableAnimalCard extends StatelessWidget {
  final AdoptableAnimalWithPlace animalWithPlace;
  final VoidCallback? onTap;
  final bool compact;

  const AdoptableAnimalCard({
    super.key,
    required this.animalWithPlace,
    this.onTap,
    this.compact = false,
  });

  AdoptableAnimal get animal => animalWithPlace.animal;
  EngagementPlace get place => animalWithPlace.place;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: animal.isUrgent || animal.isLongStay
              ? Border.all(color: MshColors.engagementHeart, width: 2)
              : null,
          boxShadow: MshColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bild
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildImage(height: 100),
                ),
                // Tierart Badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      animal.type.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                // Dringlichkeits-Badge
                if (animal.isUrgent || animal.isLongStay)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MshColors.engagementHeart,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        animal.isUrgent ? 'Dringend' : 'Lange wartend',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [animal.breed, animal.age].whereType<String>().join(' • '),
                    style: TextStyle(
                      fontSize: 11,
                      color: MshColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: MshColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.city ?? place.name,
                          style: TextStyle(
                            fontSize: 10,
                            color: MshColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: animal.isUrgent || animal.isLongStay
              ? Border.all(color: MshColors.engagementHeart, width: 2)
              : null,
          boxShadow: MshColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bild mit Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildImage(height: 180),
                ),
                
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Tierart Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(animal.type.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          animal.type.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Dringlichkeits-Banner
                if (animal.isUrgent || animal.isLongStay)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: MshColors.engagementHeart,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            animal.isUrgent 
                                ? 'Sucht dringend!' 
                                : '${animal.waitingDays} Tage wartend',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Name Overlay unten
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      if (animal.breed != null)
                        Text(
                          animal.breed!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eigenschaften
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (animal.age != null)
                        _PropertyChip(icon: Icons.cake_outlined, label: animal.age!),
                      if (animal.gender != null)
                        _PropertyChip(
                          icon: animal.gender == 'männlich' 
                              ? Icons.male 
                              : Icons.female,
                          label: animal.gender!,
                        ),
                      if (animal.size != null)
                        _PropertyChip(icon: Icons.straighten, label: animal.size!),
                    ],
                  ),
                  
                  // Beschreibung
                  if (animal.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      animal.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: MshColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Charakter
                  if (animal.character != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('💝', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            animal.character!,
                            style: TextStyle(
                              fontSize: 13,
                              color: MshColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Tierheim Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MshColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: MshColors.engagementAnimal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('🏠', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                place.city ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MshColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: MshColors.slateMuted,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Text('❤️', style: TextStyle(fontSize: 18)),
                      label: const Text('Kennenlernen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MshColors.engagementHeart,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  Widget _buildImage({required double height}) {
    if (animal.imageUrl != null && animal.imageUrl!.isNotEmpty) {
      return Image.asset(
        animal.imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(height),
      );
    }
    return _buildPlaceholder(height);
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: MshColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              animal.type.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              'Foto kommt bald',
              style: TextStyle(
                color: MshColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PropertyChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MshColors.copperSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: MshColors.copper),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: MshColors.copper,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## TEIL 5: Engagement-Widget für Home

### 5.1 Engagement Home Widget

Erstelle `lib/src/features/engagement/presentation/engagement_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/config/feature_flags.dart';
import '../application/engagement_provider.dart';
import '../domain/engagement_model.dart';
import 'adoptable_animal_card.dart';

/// Widget für die Startseite - zeigt Engagement-Möglichkeiten
class EngagementWidget extends ConsumerWidget {
  const EngagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableEngagementWidget) {
      return const SizedBox.shrink();
    }

    final urgentAnimalsAsync = ref.watch(urgentAnimalsProvider);
    final urgentNeedsAsync = ref.watch(urgentNeedsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MshColors.engagementHeart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('❤️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hilfe gesucht',
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MshColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Engagiere dich in deiner Region',
                      style: TextStyle(
                        fontSize: 13,
                        color: MshColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation zu Engagement-Übersicht
                },
                child: const Text('Alle →'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Dringende Tiere
        urgentAnimalsAsync.when(
          data: (animals) {
            if (animals.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Tiere suchen ein Zuhause',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: MshColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: MshColors.engagementHeart,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${animals.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: animals.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return AdoptableAnimalCard(
                        animalWithPlace: animals[index],
                        compact: true,
                        onTap: () {
                          // Öffne Tier-Detail
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const _LoadingPlaceholder(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 20),

        // Dringende Hilfsaufrufe
        urgentNeedsAsync.when(
          data: (needs) {
            if (needs.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('🆘', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Dringende Hilfsaufrufe',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: MshColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...needs.take(3).map((needWithPlace) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: _NeedCard(needWithPlace: needWithPlace),
                    )),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NeedCard extends StatelessWidget {
  final EngagementNeedWithPlace needWithPlace;

  const _NeedCard({required this.needWithPlace});

  @override
  Widget build(BuildContext context) {
    final need = needWithPlace.need;
    final place = needWithPlace.place;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: need.urgency.color,
            width: 4,
          ),
        ),
        boxShadow: MshColors.cardShadow,
      ),
      child: Row(
        children: [
          // Kategorie Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: need.urgency.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                need.category.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        need.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: need.urgency.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        need.urgency.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: MshColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: MshColors.slateMuted,
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(MshColors.engagementHeart),
        ),
      ),
    );
  }
}
```

---

## TEIL 6: Engagement Filter-Chips

### 6.1 Engagement Filter Bar

Erstelle `lib/src/features/engagement/presentation/engagement_filter_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../domain/engagement_model.dart';

/// Filter-Leiste für Engagement-Typen
class EngagementFilterBar extends StatelessWidget {
  final EngagementType? selectedType;
  final Function(EngagementType?) onTypeSelected;
  final Map<EngagementType, int>? counts;

  const EngagementFilterBar({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Alle" Chip
          _EngagementFilterChip(
            label: 'Alle',
            emoji: '❤️',
            isSelected: selectedType == null,
            count: counts?.values.fold(0, (a, b) => a + b),
            onTap: () => onTypeSelected(null),
          ),
          const SizedBox(width: 8),

          // Typ-Chips
          ...EngagementType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _EngagementFilterChip(
                  label: type.label,
                  emoji: type.emoji,
                  color: type.color,
                  isSelected: selectedType == type,
                  count: counts?[type],
                  onTap: () => onTypeSelected(type),
                ),
              )),
        ],
      ),
    );
  }
}

class _EngagementFilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color? color;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _EngagementFilterChip({
    required this.label,
    required this.emoji,
    this.color,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.engagementHeart;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : MshColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? chipColor : MshColors.engagementGold,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : MshColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : chipColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : chipColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Nächster Schritt

Fahre fort mit **PROMPT 09c** für:
- DeepScan Integration (Engagement-Orte automatisch finden)
- Engagement Detail-Sheet
- Integration in Karte
- Integration in Dashboard
- JSON-Datenstruktur
