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

class _WelcomeContent extends StatefulWidget {
  const _WelcomeContent({required this.onStart});
  final VoidCallback onStart;

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Feature-Kacheln in Seiten aufgeteilt (je 4 pro Seite)
  static const List<List<_FeatureData>> _featurePages = [
    // Seite 1: Kern-Features
    [
      _FeatureData(
        icon: Icons.family_restroom,
        title: 'Familie',
        desc: 'Spielplätze, Museen, Natur',
      ),
      _FeatureData(
        icon: Icons.restaurant,
        title: 'Gastronomie',
        desc: 'Restaurants & Cafés',
      ),
      _FeatureData(
        icon: Icons.event,
        title: 'Events',
        desc: 'Veranstaltungen live',
      ),
      _FeatureData(
        icon: Icons.local_hospital,
        title: 'Gesundheit',
        desc: 'Ärzte & Apotheken',
      ),
    ],
    // Seite 2: Neue Features
    [
      _FeatureData(
        icon: Icons.directions_bus,
        title: 'Mobilität',
        desc: 'ÖPNV-Abfahrten',
        isNew: true,
      ),
      _FeatureData(
        icon: Icons.people,
        title: 'Soziales',
        desc: 'Jugendzentren & Behörden',
        isNew: true,
      ),
      _FeatureData(
        icon: Icons.nightlife,
        title: 'Nachtleben',
        desc: 'Bars & Clubs',
        isNew: true,
      ),
      _FeatureData(
        icon: Icons.volunteer_activism,
        title: 'Engagement',
        desc: 'Freiwilligenarbeit',
        isNew: true,
      ),
    ],
    // Seite 3: Kupfer-Highlight + Coming Soon
    [
      _FeatureData(
        icon: Icons.directions_bike,
        title: 'Kupferspurenradweg',
        desc: '48km Bergbau-Geschichte',
        isKupfer: true,
      ),
      _FeatureData(
        icon: Icons.school,
        title: 'MSH-Wissen',
        desc: 'Wissen & Können von MSH',
        isComingSoon: true,
      ),
      _FeatureData(
        icon: Icons.storefront,
        title: 'Flohmarkt',
        desc: 'Was einer nicht braucht...',
        isComingSoon: true,
      ),
      _FeatureData(
        icon: Icons.cookie_outlined,
        title: 'Privatsphäre',
        desc: 'Keine Tracking-Cookies',
        highlight: true,
      ),
    ],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 32),

                  // Features - Horizontal scrollbare Kacheln
                  SizedBox(
                    height: 190,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: _featurePages.length,
                      itemBuilder: (context, pageIndex) {
                        final features = _featurePages[pageIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Erste Zeile (2 Kacheln)
                              Row(
                                children: [
                                  Expanded(
                                    child: _FeatureItem(
                                      icon: features[0].icon,
                                      title: features[0].title,
                                      desc: features[0].desc,
                                      highlight: features[0].highlight,
                                      isNew: features[0].isNew,
                                      isComingSoon: features[0].isComingSoon,
                                      isKupfer: features[0].isKupfer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: features.length > 1
                                        ? _FeatureItem(
                                            icon: features[1].icon,
                                            title: features[1].title,
                                            desc: features[1].desc,
                                            highlight: features[1].highlight,
                                            isNew: features[1].isNew,
                                            isComingSoon: features[1].isComingSoon,
                                            isKupfer: features[1].isKupfer,
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Zweite Zeile (2 Kacheln falls vorhanden)
                              if (features.length > 2)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _FeatureItem(
                                        icon: features[2].icon,
                                        title: features[2].title,
                                        desc: features[2].desc,
                                        highlight: features[2].highlight,
                                        isNew: features[2].isNew,
                                        isComingSoon: features[2].isComingSoon,
                                        isKupfer: features[2].isKupfer,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: features.length > 3
                                          ? _FeatureItem(
                                              icon: features[3].icon,
                                              title: features[3].title,
                                              desc: features[3].desc,
                                              highlight: features[3].highlight,
                                              isNew: features[3].isNew,
                                              isComingSoon: features[3].isComingSoon,
                                              isKupfer: features[3].isKupfer,
                                            )
                                          : const SizedBox(),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Seiten-Indikatoren (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _featurePages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? MshColors.primary
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Swipe-Hinweis
                  Text(
                    '← Wischen für mehr Features →',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onStart,
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

/// Datenklasse für Feature-Kacheln
class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.desc,
    this.highlight = false,
    this.isNew = false,
    this.isComingSoon = false,
    this.isKupfer = false,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool highlight;
  final bool isNew;
  final bool isComingSoon;
  final bool isKupfer;
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
    this.highlight = false,
    this.isNew = false,
    this.isComingSoon = false,
    this.isKupfer = false,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool highlight;
  final bool isNew;
  final bool isComingSoon;
  final bool isKupfer;

  // Kupferfarbe
  static const _kupferColor = Color(0xFFB87333);

  @override
  Widget build(BuildContext context) {
    // Coming Soon hat eigenen Stil
    final Color bgColor;
    final BoxBorder? border;
    final Color iconColor;
    final List<BoxShadow>? boxShadow;

    if (isKupfer) {
      bgColor = _kupferColor.withValues(alpha: 0.2);
      border = Border.all(color: _kupferColor, width: 2);
      iconColor = _kupferColor;
      boxShadow = [
        BoxShadow(
          color: _kupferColor.withValues(alpha: 0.4),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (isComingSoon) {
      bgColor = Colors.white.withValues(alpha: 0.03);
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        style: BorderStyle.solid,
      );
      iconColor = Colors.white38;
      boxShadow = null;
    } else if (highlight) {
      bgColor = MshColors.success.withValues(alpha: 0.15);
      border = Border.all(color: MshColors.success.withValues(alpha: 0.3));
      iconColor = MshColors.success;
      boxShadow = null;
    } else if (isNew) {
      bgColor = MshColors.primary.withValues(alpha: 0.15);
      border = Border.all(color: MshColors.primary.withValues(alpha: 0.3));
      iconColor = MshColors.primary;
      boxShadow = null;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.05);
      border = null;
      iconColor = MshColors.primary;
      boxShadow = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 26,
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
              if (isComingSoon)
                Positioned(
                  top: -4,
                  right: -16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BALD',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isKupfer)
                Positioned(
                  top: -6,
                  right: -18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _kupferColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: _kupferColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
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
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isComingSoon ? Colors.white54 : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              color: isComingSoon ? Colors.white38 : Colors.white60,
              fontSize: 10,
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
