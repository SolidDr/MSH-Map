import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/constants/app_strings.dart';

class WelcomeOverlay extends StatefulWidget {

  const WelcomeOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<WelcomeOverlay> createState() => _WelcomeOverlayState();
}

class _WelcomeOverlayState extends State<WelcomeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _showOverlay = true;
  bool _isLoading = true;

  // LocalStorage Key für Timestamp der letzten Anzeige
  static const _lastSeenKey = 'msh_welcome_last_seen';

  // Cooldown: Nicht erneut anzeigen wenn innerhalb dieser Zeit geöffnet
  static const _cooldownMinutes = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenTimestamp = prefs.getInt(_lastSeenKey);

    var shouldShow = true;

    if (lastSeenTimestamp != null) {
      final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenTimestamp);
      final difference = DateTime.now().difference(lastSeen);

      // Nicht anzeigen wenn weniger als _cooldownMinutes vergangen sind
      if (difference.inMinutes < _cooldownMinutes) {
        shouldShow = false;
      }
    }

    setState(() {
      _showOverlay = shouldShow;
      _isLoading = false;
    });
  }

  Future<void> _dismiss() async {
    _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Speichere aktuellen Timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSeenKey, DateTime.now().millisecondsSinceEpoch);

    setState(() => _showOverlay = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_showOverlay)
            FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(_fadeAnimation),
              child: GestureDetector(
                onTap: _dismiss,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity!.abs() > 100) {
                    _dismiss();
                  }
                },
                child: _WelcomeContent(onStart: _dismiss),
              ),
            ),
        ],
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {

  const _WelcomeContent({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF0000000),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MshColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map,
                      size: 48,
                      color: MshColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titel
                  const Text(
                    'Willkommen bei',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.appTagline,
                    style: TextStyle(
                      color: MshColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 39),

                  // Features - Module-Übersicht
                  const Row(
                    children: [
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.family_restroom,
                          title: 'Familie',
                          desc: 'Spielplätze, Museen, Natur',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.restaurant,
                          title: 'Gastronomie',
                          desc: 'Restaurants & Cafés',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.event,
                          title: 'Events',
                          desc: 'Veranstaltungen live',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.local_hospital,
                          title: 'Gesundheit',
                          desc: 'Ärzte & Apotheken',
                          isNew: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.directions_bus,
                          title: 'Mobilität',
                          desc: 'ÖPNV-Abfahrten',
                          isNew: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.cookie_outlined,
                          title: 'Privatsphäre',
                          desc: 'Keine Tracking-Cookies',
                          highlight: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 39),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MshColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Karte öffnen',
                        style:
                            TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Tippen oder wischen zum Starten',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
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

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
    this.highlight = false,
    this.isNew = false,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool highlight;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? MshColors.success.withValues(alpha: 0.15)
            : isNew
                ? MshColors.primary.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: MshColors.success.withValues(alpha: 0.3))
            : isNew
                ? Border.all(color: MshColors.primary.withValues(alpha: 0.3))
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: highlight
                    ? MshColors.success
                    : isNew
                        ? MshColors.primary
                        : MshColors.primary,
                size: 32,
              ),
              if (isNew)
                Positioned(
                  top: -4,
                  right: -12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: MshColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
