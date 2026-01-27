/// MSH Map - Spacing System
///
/// Basierend auf der Fibonacci-Sequenz für harmonische Proportionen
/// und dem Goldenen Schnitt (φ = 1.618)
library;

import 'package:flutter/material.dart';

class MshSpacing {
  MshSpacing._();

  // ═══════════════════════════════════════════════════════════════
  // FIBONACCI SPACING - Harmonische Proportionen
  // ═══════════════════════════════════════════════════════════════

  /// Extra Small - 5px (Fibonacci 5)
  /// Verwendung: Minimale Abstände, Icon-Padding
  static const double xs = 5;

  /// Small - 8px (Fibonacci 8)
  /// Verwendung: Chip-Gaps, kleine Abstände zwischen Elementen
  static const double sm = 8;

  /// Medium - 13px (Fibonacci 13)
  /// Verwendung: Card-Padding, Checkbox vertical padding
  static const double md = 13;

  /// Large - 21px (Fibonacci 21)
  /// Verwendung: Card-Margin, Screen horizontal padding, Button padding
  static const double lg = 21;

  /// Extra Large - 34px (Fibonacci 34)
  /// Verwendung: Section-Spacing, große Abstände zwischen Gruppen
  static const double xl = 34;

  /// Extra Extra Large - 55px (Fibonacci 55)
  /// Verwendung: AppBar Höhe, große visuelle Trennung
  static const double xxl = 55;

  // ═══════════════════════════════════════════════════════════════
  // GOLDENER SCHNITT KONSTANTEN
  // ═══════════════════════════════════════════════════════════════

  /// Goldener Schnitt - φ (Phi) = 1.618
  /// Verhältnis für harmonische Proportionen
  static const double phi = 1.618;

  /// Inverser Goldener Schnitt - 1/φ = 0.618
  /// Verwendung für kleinere Teile im Verhältnis
  static const double phiInverse = 0.618;

  // ═══════════════════════════════════════════════════════════════
  // HELPER FUNKTIONEN
  // ═══════════════════════════════════════════════════════════════

  /// Berechnet den größeren Teil basierend auf dem Goldenen Schnitt
  ///
  /// Beispiel: goldenRatio(100) = 161.8
  static double goldenRatio(double base) => base * phi;

  /// Berechnet den kleineren Teil basierend auf dem Goldenen Schnitt
  ///
  /// Beispiel: goldenInverse(100) = 61.8
  static double goldenInverse(double base) => base * phiInverse;

  /// Teilt eine Größe nach dem Goldenen Schnitt
  ///
  /// Returns: (größerer Teil, kleinerer Teil)
  /// Beispiel: divideByGoldenRatio(100) = (61.8, 38.2)
  static (double, double) divideByGoldenRatio(double total) {
    final larger = total * phiInverse;
    final smaller = total * (1 - phiInverse);
    return (larger, smaller);
  }

  // ═══════════════════════════════════════════════════════════════
  // RESPONSIVE SPACING - Basierend auf Viewport
  // ═══════════════════════════════════════════════════════════════

  /// Screen Padding Horizontal - 21px (lg)
  static const double screenPaddingHorizontal = lg;

  /// Screen Padding Vertical - 13px (md)
  static const double screenPaddingVertical = md;

  /// Minimale Touch-Target Größe (Accessibility)
  static const double minTouchTarget = 48;

  // ═══════════════════════════════════════════════════════════════
  // SPEZIELLE ABSTÄNDE
  // ═══════════════════════════════════════════════════════════════

  /// Card Stack Spacing - für überlappende Cards
  static const double cardStack = sm; // 8px

  /// List Item Spacing - zwischen List Items
  static const double listItem = md; // 13px

  /// Section Divider - zwischen großen Sections
  static const double sectionDivider = xl; // 34px

  /// Bottom Sheet Drag Handle Height
  static const double dragHandle = xs; // 5px

  /// Bottom Sheet Drag Handle Width
  static const double dragHandleWidth = 40;

  /// Bottom Sheet Top Radius (xxl für smooth transition)
  static const double bottomSheetRadius = xl; // 34px

  // ═══════════════════════════════════════════════════════════════
  // VIEWPORT RATIO HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Map View Ratio - 80% der Viewport Höhe
  /// Basiert auf Goldener Schnitt (grob: 0.8 ≈ φ/(φ+1))
  static const double mapViewRatio = 0.8;

  /// Bottom Content Ratio - 20% der Viewport Höhe
  static const double bottomContentRatio = 0.2;

  /// Bottom Content Min Size - minimiert
  static const double bottomContentMinSize = 0.08;

  /// Bottom Content Max Size - expandiert
  static const double bottomContentMaxSize = 0.6;

  /// Sheet Default Size - basierend auf φ^-1
  static const double sheetDefaultSize = phiInverse; // 0.618

  /// Sheet Medium Size - basierend auf φ^-2
  static const double sheetMediumSize = 0.382; // φ^-2 ≈ 0.382

  /// Sheet Min Size
  static const double sheetMinSize = 0.2;

  /// Sheet Max Size
  static const double sheetMaxSize = 1;

  // ═══════════════════════════════════════════════════════════════
  // EDGE INSETS PRESETS
  // ═══════════════════════════════════════════════════════════════

  /// Screen Padding - 21px horizontal, 13px vertical
  static const screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  /// Card Padding - 13px all around
  static const cardPadding = EdgeInsets.all(md);

  /// Card Margin - 21px all around
  static const cardMargin = EdgeInsets.all(lg);

  /// Button Padding - 21px horizontal, 13px vertical
  static const buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Chip Padding - 13px horizontal, 8px vertical
  static const chipPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// List Item Padding - 21px horizontal, 13px vertical
  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}
