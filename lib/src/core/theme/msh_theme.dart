import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'msh_colors.dart';
import 'msh_spacing.dart';

class MshTheme {
  MshTheme._();

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADIUS (Runde, freundliche UI)
  // Basierend auf Fibonacci-Sequenz
  // ═══════════════════════════════════════════════════════════════

  static const double radiusSmall = MshSpacing.sm;      // 8px
  static const double radiusMedium = MshSpacing.md;     // 13px
  static const double radiusLarge = MshSpacing.lg;      // 21px
  static const double radiusXLarge = MshSpacing.xl;     // 34px
  static const double radiusRound = 100;              // Für Pills/Chips

  // ═══════════════════════════════════════════════════════════════
  // SPACING - Verwenden MshSpacing (Fibonacci)
  // ═══════════════════════════════════════════════════════════════

  @Deprecated('Use MshSpacing.xs instead')
  static const double spacingXs = MshSpacing.xs;
  @Deprecated('Use MshSpacing.sm instead')
  static const double spacingSm = MshSpacing.sm;
  @Deprecated('Use MshSpacing.md instead')
  static const double spacingMd = MshSpacing.md;
  @Deprecated('Use MshSpacing.lg instead')
  static const double spacingLg = MshSpacing.lg;
  @Deprecated('Use MshSpacing.xl instead')
  static const double spacingXl = MshSpacing.xl;

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Farben
    colorScheme: ColorScheme.light(
      primary: MshColors.primary,
      primaryContainer: MshColors.primarySubtle,
      secondary: MshColors.secondary,
      secondaryContainer: MshColors.secondaryLight.withValues(alpha: 0.2),
      error: MshColors.error,
      onSecondary: MshColors.textOnPrimary,
      onSurface: MshColors.textPrimary,
    ),

    // Scaffold
    scaffoldBackgroundColor: MshColors.background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: MshColors.surface,
      foregroundColor: MshColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: MshColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Cards (rund und weich)
    cardTheme: CardThemeData(
      color: MshColors.surface,
      elevation: 2,
      shadowColor: MshColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.all(MshSpacing.sm),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MshColors.primary,
        foregroundColor: MshColors.textOnPrimary,
        elevation: 2,
        shadowColor: MshColors.primary.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MshColors.primary,
        side: const BorderSide(color: MshColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MshColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MshColors.primary,
      foregroundColor: MshColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Chips (für Filter, Tags)
    chipTheme: ChipThemeData(
      backgroundColor: MshColors.surfaceVariant,
      selectedColor: MshColors.primarySubtle,
      labelStyle: const TextStyle(color: MshColors.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MshColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: MshColors.surfaceVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: MshColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: MshColors.textSecondary),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MshColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXLarge)),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MshColors.textPrimary,
      contentTextStyle: const TextStyle(color: MshColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: MshColors.surfaceVariant,
      thickness: 1,
      space: MshSpacing.md,
    ),

    // Text - mit Goldener Schnitt Line Height (1.618)
    // Noto Sans für vollständige Unicode-Unterstützung
    textTheme: GoogleFonts.notoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 55,                          // Fibonacci 55
          fontWeight: FontWeight.bold,
          color: MshColors.textStrong,
          height: MshSpacing.phi,                 // 1.618 line height
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 34,                          // Fibonacci 34
          fontWeight: FontWeight.bold,
          color: MshColors.textStrong,
          height: MshSpacing.phi,                 // 1.618
        ),
        headlineLarge: TextStyle(
          fontSize: 21,                          // Fibonacci 21
          fontWeight: FontWeight.w600,
          color: MshColors.textPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MshColors.textPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MshColors.textPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MshColors.textPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: MshColors.textPrimary,
          height: MshSpacing.phi,                 // 1.618 - optimal für Lesbarkeit
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: MshColors.textSecondary,
          height: MshSpacing.phi,                 // 1.618
        ),
        labelLarge: TextStyle(
          fontSize: 13,                          // Fibonacci 13
          fontWeight: FontWeight.w600,
          color: MshColors.textPrimary,
          height: 1.4,                           // Etwas kompakter für Labels
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MshColors.textSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: MshColors.textMuted,
          height: 1.3,
        ),
      ),
    ),

    // Navigation Bar (Bottom Nav)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MshColors.surface,
      indicatorColor: MshColors.primary.withValues(alpha: 0.15),
      height: 65,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, color: MshColors.textSecondary),
      ),
    ),

    // Navigation Rail
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: MshColors.surface,
      selectedIconTheme: IconThemeData(color: MshColors.primary),
      unselectedIconTheme: IconThemeData(color: MshColors.textSecondary),
      selectedLabelTextStyle: TextStyle(color: MshColors.primary),
      unselectedLabelTextStyle: TextStyle(color: MshColors.textSecondary),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME - Modernes, ansprechendes Dark Design
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Farben
    colorScheme: ColorScheme.dark(
      primary: MshColors.darkPrimary,
      primaryContainer: MshColors.darkPrimarySurface,
      secondary: MshColors.darkPrimaryLight,
      secondaryContainer: MshColors.darkPrimarySurface.withValues(alpha: 0.3),
      surface: MshColors.darkSurface,
      surfaceContainerHighest: MshColors.darkSurfaceElevated,
      error: MshColors.error,
      onPrimary: MshColors.darkBackground,
      onSecondary: MshColors.darkBackground,
      onSurface: MshColors.darkTextPrimary,
    ),

    // Scaffold
    scaffoldBackgroundColor: MshColors.darkBackground,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: MshColors.darkSurface,
      foregroundColor: MshColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: MshColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: MshColors.darkSurface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.all(MshSpacing.sm),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MshColors.darkPrimary,
        foregroundColor: MshColors.darkBackground,
        elevation: 2,
        shadowColor: MshColors.darkPrimary.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MshColors.darkPrimary,
        side: const BorderSide(color: MshColors.darkPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MshColors.darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MshColors.darkPrimary,
      foregroundColor: MshColors.darkBackground,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: MshColors.darkSurfaceVariant,
      selectedColor: MshColors.darkPrimarySurface,
      labelStyle: const TextStyle(color: MshColors.darkTextPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MshColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: MshColors.darkSurfaceVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: MshColors.darkPrimary, width: 2),
      ),
      hintStyle: const TextStyle(color: MshColors.darkTextSecondary),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MshColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXLarge)),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MshColors.darkSurfaceElevated,
      contentTextStyle: const TextStyle(color: MshColors.darkTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: MshColors.darkSurfaceVariant,
      thickness: 1,
      space: MshSpacing.md,
    ),

    // Text - mit Goldener Schnitt Line Height (1.618)
    // Noto Sans für vollständige Unicode-Unterstützung
    textTheme: GoogleFonts.notoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 55,                          // Fibonacci 55
          fontWeight: FontWeight.bold,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618 line height
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 34,                          // Fibonacci 34
          fontWeight: FontWeight.bold,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        headlineLarge: TextStyle(
          fontSize: 21,                          // Fibonacci 21
          fontWeight: FontWeight.w600,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: MshColors.darkTextPrimary,
          height: MshSpacing.phi,                 // 1.618 - optimal für Lesbarkeit
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: MshColors.darkTextSecondary,
          height: MshSpacing.phi,                 // 1.618
        ),
        labelLarge: TextStyle(
          fontSize: 13,                          // Fibonacci 13
          fontWeight: FontWeight.w600,
          color: MshColors.darkTextPrimary,
          height: 1.4,                           // Etwas kompakter für Labels
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MshColors.darkTextSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: MshColors.darkTextSecondary,
          height: 1.3,
        ),
      ),
    ),

    // Navigation Bar (Bottom Nav)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MshColors.darkSurface,
      indicatorColor: MshColors.darkPrimary.withValues(alpha: 0.3),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, color: MshColors.darkTextSecondary),
      ),
    ),

    // Navigation Rail
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: MshColors.darkSurface,
      selectedIconTheme: IconThemeData(color: MshColors.darkPrimary),
      unselectedIconTheme: IconThemeData(color: MshColors.darkTextSecondary),
      selectedLabelTextStyle: TextStyle(color: MshColors.darkPrimary),
      unselectedLabelTextStyle: TextStyle(color: MshColors.darkTextSecondary),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // HIGH CONTRAST THEME (für Accessibility)
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get highContrast => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: MshColors.highContrastPrimary,
      surface: MshColors.highContrastSurface,
      error: Color(0xFFFF4444),
    ),

    scaffoldBackgroundColor: MshColors.highContrastBackground,

    cardTheme: CardThemeData(
      color: MshColors.highContrastSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: const BorderSide(color: MshColors.highContrastBorder, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MshColors.highContrastPrimary,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: MshColors.highContrastBorder, width: 2),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        color: MshColors.highContrastText,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: MshColors.highContrastText,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
