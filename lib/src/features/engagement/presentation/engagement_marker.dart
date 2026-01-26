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
