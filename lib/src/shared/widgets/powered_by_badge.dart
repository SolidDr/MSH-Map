import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Powered by KOLAN Tensor search" Badge
/// Klickbar, verlinkt auf tensorsearch.de
class PoweredByBadge extends StatelessWidget {
  const PoweredByBadge({
    super.key,
    this.compact = false,
    this.textColor,
  });

  final bool compact;
  final Color? textColor;

  static const _tensorUrl = 'https://kolan-systems.de';
  static const _goldColor = Color(0xFFC9A227);
  static const _darkBg = Color(0xFF0A0A0D);

  Future<void> _launchUrl() async {
    final uri = Uri.parse(_tensorUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _darkBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hexagon Icon
            const _HexagonIcon(size: 16),
            const SizedBox(width: 8),
            // Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'KOLAN ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _goldColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Tensor',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'search',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull() {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _darkBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hexagon Icon
            const _HexagonIcon(size: 22),
            const SizedBox(width: 10),
            // Text Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Powered by',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF666666),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'KOLAN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _goldColor,
                            ),
                          ),
                          TextSpan(
                            text: '  Tensor',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFBBBBBB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'search',
                      style: TextStyle(
                        fontSize: 7,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated Hexagon Icon für den Badge
class _HexagonIcon extends StatefulWidget {
  const _HexagonIcon({required this.size});

  final double size;

  @override
  State<_HexagonIcon> createState() => _HexagonIconState();
}

class _HexagonIconState extends State<_HexagonIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _HexagonPainter(
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  _HexagonPainter({required this.progress});

  final double progress;

  static const _goldColor = Color(0xFFC9A227);
  static const _greenColor = Color(0xFF3A5A4A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Pulsating center circle
    final pulseRadius = radius * 0.35 + (radius * 0.1 * (0.5 + 0.5 * math.sin(progress * 2 * math.pi).abs()));
    final centerPaint = Paint()..color = _goldColor;
    canvas.drawCircle(center, pulseRadius, centerPaint);

    // Outer ring (fading)
    final ringRadius = radius * 0.35 + (radius * 0.45 * progress);
    final ringOpacity = (0.35 * (1 - progress)).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = _goldColor.withValues(alpha: ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawCircle(center, ringRadius, ringPaint);

    // Hexagon outline with gradient
    final hexPath = _createHexagonPath(center, radius * 0.9);
    final hexPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_greenColor, _goldColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Animated dash
    final pathMetrics = hexPath.computeMetrics().first;
    final dashLength = pathMetrics.length * progress;
    final extractPath = pathMetrics.extractPath(0, dashLength);
    canvas.drawPath(extractPath, hexPaint..color = hexPaint.color.withValues(alpha: 0.6));
  }

  Path _createHexagonPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => oldDelegate.progress != progress;
}
