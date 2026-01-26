import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accessibility Settings Provider
final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
  return AccessibilityNotifier();
});

class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilityNotifier() : super(const AccessibilitySettings()) {
    _loadSettings();
  }

  static const _keyHighContrast = 'accessibility_high_contrast';
  static const _keyTextScale = 'accessibility_text_scale';
  static const _keyReduceAnimations = 'accessibility_reduce_animations';
  static const _keyLargeButtons = 'accessibility_large_buttons';
  static const _keyBoldText = 'accessibility_bold_text';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AccessibilitySettings(
      highContrast: prefs.getBool(_keyHighContrast) ?? false,
      textScale: prefs.getDouble(_keyTextScale) ?? 1.0,
      reduceAnimations: prefs.getBool(_keyReduceAnimations) ?? false,
      largeButtons: prefs.getBool(_keyLargeButtons) ?? false,
      boldText: prefs.getBool(_keyBoldText) ?? false,
    );
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHighContrast, value);
  }

  Future<void> setTextScale(double value) async {
    state = state.copyWith(textScale: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextScale, value);
  }

  Future<void> setReduceAnimations(bool value) async {
    state = state.copyWith(reduceAnimations: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceAnimations, value);
  }

  Future<void> setLargeButtons(bool value) async {
    state = state.copyWith(largeButtons: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLargeButtons, value);
  }

  Future<void> setBoldText(bool value) async {
    state = state.copyWith(boldText: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBoldText, value);
  }

  Future<void> resetToDefaults() async {
    state = const AccessibilitySettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHighContrast);
    await prefs.remove(_keyTextScale);
    await prefs.remove(_keyReduceAnimations);
    await prefs.remove(_keyLargeButtons);
    await prefs.remove(_keyBoldText);
  }
}

/// Accessibility Settings Data Class
class AccessibilitySettings {
  final bool highContrast;
  final double textScale;
  final bool reduceAnimations;
  final bool largeButtons;
  final bool boldText;

  const AccessibilitySettings({
    this.highContrast = false,
    this.textScale = 1.0,
    this.reduceAnimations = false,
    this.largeButtons = false,
    this.boldText = false,
  });

  AccessibilitySettings copyWith({
    bool? highContrast,
    double? textScale,
    bool? reduceAnimations,
    bool? largeButtons,
    bool? boldText,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      textScale: textScale ?? this.textScale,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      largeButtons: largeButtons ?? this.largeButtons,
      boldText: boldText ?? this.boldText,
    );
  }

  /// Helper: Berechne tatsächliche Schriftgröße
  double getScaledFontSize(double baseSize) => baseSize * textScale;

  /// Helper: Berechne Button-Höhe
  double getButtonHeight(double baseHeight) =>
      largeButtons ? baseHeight * 1.3 : baseHeight;

  /// Helper: Berechne Animations-Dauer
  Duration getAnimationDuration(Duration baseDuration) =>
      reduceAnimations ? Duration.zero : baseDuration;

  /// Helper: Gibt FontWeight zurück (bold wenn aktiviert)
  FontWeight getTextWeight(FontWeight baseWeight) {
    if (!boldText) return baseWeight;
    return baseWeight == FontWeight.normal ? FontWeight.w600 : FontWeight.bold;
  }
}
