import 'package:flutter/widgets.dart';

/// Widget das seinen Child nur anzeigt wenn das Feature aktiviert ist
class FeatureFlag extends StatelessWidget {
  const FeatureFlag({
    required this.isEnabled,
    required this.child,
    this.fallback,
    super.key,
  });
  final bool isEnabled;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (isEnabled) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

/// Extension für einfachere Verwendung
extension FeatureFlagExtension on Widget {
  Widget withFeatureFlag({required bool isEnabled, Widget? fallback}) {
    return FeatureFlag(
      isEnabled: isEnabled,
      fallback: fallback,
      child: this,
    );
  }
}
