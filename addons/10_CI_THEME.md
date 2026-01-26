# 10 - Corporate Identity & Theme

## KOLAN Systems CI → MSH Map Adaption

Die MSH Map übernimmt die CI von KOLAN Systems, adaptiert sie aber für eine **familien- und freundliche Ausstrahlung**.

---

## Farbpalette

### Primärfarben (Warm Amber)

```dart
// lib/src/core/theme/msh_colors.dart

import 'package:flutter/material.dart';

class MshColors {
  MshColors._();
  
  // ═══════════════════════════════════════════════════════════════
  // PRIMÄR: Warmes Amber (freundlich, einladend)
  // ═══════════════════════════════════════════════════════════════
  
  static const Color primary = Color(0xFFF59E0B);        // Amber 500
  static const Color primaryLight = Color(0xFFFBBF24);   // Amber 400
  static const Color primaryDark = Color(0xFFD97706);    // Amber 600
  static const Color primarySurface = Color(0xFFFEF3C7); // Amber 100
  
  // ═══════════════════════════════════════════════════════════════
  // SEKUNDÄR: Warmes Orange (Akzent)
  // ═══════════════════════════════════════════════════════════════
  
  static const Color secondary = Color(0xFFEA580C);      // Orange 600
  static const Color secondaryLight = Color(0xFFFB923C); // Orange 400
  
  // ═══════════════════════════════════════════════════════════════
  // NEUTRAL: Warmes Grau
  // ═══════════════════════════════════════════════════════════════
  
  static const Color background = Color(0xFFFFFBEB);     // Amber 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFEF3C7); // Amber 100
  
  static const Color textPrimary = Color(0xFF292524);    // Stone 800
  static const Color textSecondary = Color(0xFF78716C);  // Stone 500
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ═══════════════════════════════════════════════════════════════
  // KATEGORIE-FARBEN (für Map-Marker)
  // ═══════════════════════════════════════════════════════════════
  
  static const Color categoryFamily = Color(0xFFF59E0B);     // Amber - Familie
  static const Color categoryPlayground = Color(0xFF10B981); // Emerald - Spielplatz
  static const Color categoryNature = Color(0xFF22C55E);     // Green - Natur
  static const Color categoryMuseum = Color(0xFF8B5CF6);     // Violet - Museum
  static const Color categoryCastle = Color(0xFFEC4899);     // Pink - Burg
  static const Color categoryPool = Color(0xFF06B6D4);       // Cyan - Wasser
  static const Color categoryGastro = Color(0xFFEF4444);     // Red - Gastro
  static const Color categoryEvent = Color(0xFF6366F1);      // Indigo - Event
  
  // ═══════════════════════════════════════════════════════════════
  // STATUS
  // ═══════════════════════════════════════════════════════════════
  
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
```

---

## Theme Definition

```dart
// lib/src/core/theme/msh_theme.dart

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
  static const double radiusRound = 100.0;  // Für Pills/Chips
  
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
      secondaryContainer: MshColors.secondaryLight.withOpacity(0.2),
      surface: MshColors.surface,
      background: MshColors.background,
      error: MshColors.error,
      onPrimary: MshColors.textOnPrimary,
      onSecondary: MshColors.textOnPrimary,
      onSurface: MshColors.textPrimary,
      onBackground: MshColors.textPrimary,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: MshColors.background,
    
    // AppBar
    appBarTheme: AppBarTheme(
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
    cardTheme: CardTheme(
      color: MshColors.surface,
      elevation: 2,
      shadowColor: MshColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: EdgeInsets.all(spacingSm),
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MshColors.primary,
        foregroundColor: MshColors.textOnPrimary,
        elevation: 2,
        shadowColor: MshColors.primary.withOpacity(0.3),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MshColors.primary,
        side: BorderSide(color: MshColors.primary, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MshColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      labelStyle: TextStyle(color: MshColors.textPrimary),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
    ),
    
    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MshColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide(color: MshColors.surfaceVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide(color: MshColors.primary, width: 2),
      ),
      hintStyle: TextStyle(color: MshColors.textSecondary),
    ),
    
    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: MshColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXLarge)),
      ),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MshColors.textPrimary,
      contentTextStyle: TextStyle(color: MshColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: MshColors.surfaceVariant,
      thickness: 1,
      space: spacingMd,
    ),
    
    // Text
    textTheme: TextTheme(
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
  // DARK THEME (Optional, für später)
  // ═══════════════════════════════════════════════════════════════
  
  static ThemeData get dark => light.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1C1917),
    colorScheme: ColorScheme.dark(
      primary: MshColors.primaryLight,
      primaryContainer: MshColors.primaryDark,
      surface: Color(0xFF292524),
      background: Color(0xFF1C1917),
    ),
  );
}
```

---

## Logo-Assets

Benötigte Dateien in `assets/images/`:

```
assets/
├── images/
│   ├── logo_msh_map.svg          # Haupt-Logo
│   ├── logo_msh_map_light.svg    # Für dunkle Hintergründe
│   ├── logo_kolan_badge.svg      # "Powered by" Badge
│   └── icon_app.png              # App Icon (1024x1024)
└── fonts/
    └── (optional: Custom Font)
```

---

## Beispiel: Logo-Vorschlag

```
   ╭──────────────────────╮
   │  🗺️  MSH Map        │
   │  Mansfeld-Südharz    │
   │  entdecken          │
   ╰──────────────────────╯
```

**Stil:**
- Runde, freundliche Form
- Amber/Orange Farbverlauf
- Einfaches Karten-Icon
- Handschrift-artige oder runde Sans-Serif Schrift

---

## CSS/Design Tokens (für Dokumentation)

```css
:root {
  /* Primary */
  --color-primary: #F59E0B;
  --color-primary-light: #FBBF24;
  --color-primary-dark: #D97706;
  --color-primary-surface: #FEF3C7;
  
  /* Text */
  --color-text-primary: #292524;
  --color-text-secondary: #78716C;
  
  /* Background */
  --color-background: #FFFBEB;
  --color-surface: #FFFFFF;
  
  /* Border Radius */
  --radius-small: 8px;
  --radius-medium: 12px;
  --radius-large: 16px;
  --radius-xlarge: 24px;
  --radius-round: 100px;
  
  /* Shadows */
  --shadow-soft: 0 2px 8px rgba(245, 158, 11, 0.15);
  --shadow-medium: 0 4px 16px rgba(245, 158, 11, 0.2);
}
```
