import 'package:flutter/material.dart';

/// #update_warning
///
/// Wartungs-Banner der die App vollständig blockiert.
///
/// Verwendung in app.dart:
/// ```dart
/// return UpdateWarning(
///   enabled: true,  // true = Banner aktiv, false = App normal nutzbar
///   child: WelcomeOverlay(...),
/// );
/// ```
class UpdateWarning extends StatelessWidget {
  const UpdateWarning({
    required this.child,
    this.enabled = false,
    super.key,
  });

  final Widget child;

  /// Wenn true, wird der Warnbanner angezeigt und blockiert die App
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // App im Hintergrund (nicht interaktiv)
          IgnorePointer(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.darken,
              ),
              child: child,
            ),
          ),
          // Blockierender Overlay
          const _UpdateWarningContent(),
        ],
      ),
    );
  }
}

class _UpdateWarningContent extends StatefulWidget {
  const _UpdateWarningContent();

  @override
  State<_UpdateWarningContent> createState() => _UpdateWarningContentState();
}

class _UpdateWarningContentState extends State<_UpdateWarningContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF5000000),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animiertes Warn-Icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.construction_rounded,
                            size: 64,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Haupttitel
                  const Text(
                    'Wartungsarbeiten',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Untertitel
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Kritisches Update wird eingespielt',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Beschreibungstext
                  const Text(
                    'Wir aktualisieren gerade die App, um dir '
                    'ein besseres Erlebnis zu bieten.\n\n'
                    'Die App ist vorübergehend nicht verfügbar. '
                    'Bitte versuche es später erneut.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Lade-Indikator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Update läuft...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Hinweis-Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Keine Sorge - deine Daten sind sicher. '
                            'Die Wartung dauert normalerweise nur wenige Minuten.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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
