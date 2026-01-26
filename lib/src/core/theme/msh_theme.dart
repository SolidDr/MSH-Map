import 'package:flutter/material.dart';
import 'msh_colors.dart';

class MshTheme {
  MshTheme._();

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADIUS (Runde, freundliche UI)
  // ═══════════════════════════════════════════════════════════════

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0; // Für Pills/Chips

  // ═══════════════════════════════════════════════════════════════
  // SPACING
  // ═══════════════════════════════════════════════════════════════

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Farben
    colorScheme: ColorScheme.light(
      primary: MshColors.primary,
      primaryContainer: MshColors.primarySurface,
      secondary: MshColors.secondary,
      secondaryContainer: MshColors.secondaryLight.withValues(alpha: 0.2),
      surface: MshColors.surface,
      error: MshColors.error,
      onPrimary: MshColors.textOnPrimary,
      onSecondary: MshColors.textOnPrimary,
      onSurface: MshColors.textPrimary,
    ),

    // Scaffold
    scaffoldBackgroundColor: MshColors.background,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: MshColors.surface,
      foregroundColor: MshColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
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
      margin: const EdgeInsets.all(spacingSm),
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
      selectedColor: MshColors.primarySurface,
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
        borderSide: const BorderSide(color: MshColors.surfaceVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: MshColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: MshColors.textSecondary),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: MshColors.surface,
      shape: const RoundedRectangleBorder(
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
      space: spacingMd,
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: MshColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: MshColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: MshColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MshColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: MshColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: MshColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: MshColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: MshColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: MshColors.textPrimary,
      ),
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
    appBarTheme: AppBarTheme(
      backgroundColor: MshColors.darkSurface,
      foregroundColor: MshColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
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
      margin: const EdgeInsets.all(spacingSm),
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
        borderSide: const BorderSide(color: MshColors.darkSurfaceVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: MshColors.darkPrimary, width: 2),
      ),
      hintStyle: const TextStyle(color: MshColors.darkTextSecondary),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: MshColors.darkSurface,
      shape: const RoundedRectangleBorder(
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
      space: spacingMd,
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: MshColors.darkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: MshColors.darkTextPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: MshColors.darkTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MshColors.darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: MshColors.darkTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: MshColors.darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: MshColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: MshColors.darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: MshColors.darkTextPrimary,
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
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: MshColors.darkSurface,
      selectedIconTheme: const IconThemeData(color: MshColors.darkPrimary),
      unselectedIconTheme: const IconThemeData(color: MshColors.darkTextSecondary),
      selectedLabelTextStyle: const TextStyle(color: MshColors.darkPrimary),
      unselectedLabelTextStyle: const TextStyle(color: MshColors.darkTextSecondary),
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
      onPrimary: Colors.black,
      onSurface: MshColors.highContrastText,
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
