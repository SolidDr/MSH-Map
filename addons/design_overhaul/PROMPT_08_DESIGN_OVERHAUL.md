# PROMPT 08: MSH Map Design-Overhaul - "Heimat MSH"

## Kontext

Du führst ein umfassendes Design-Redesign der MSH Map App durch. Die App soll die regionale Identität von **Mansfeld-Südharz** transportieren und den Menschen ein Gefühl von **Heimat, Vertrautheit und Wohlbefinden** vermitteln.

### Regionale Identität

```
MANSFELD-SÜDHARZ
═══════════════════════════════════════════════════════════════
⛏️  800+ Jahre Kupferschiefer-Bergbau (Mansfelder Kupfer)
🌹  Europa-Rosarium Sangerhausen (größte Rosensammlung der Welt)
✝️  Lutherstadt Eisleben (Geburts- & Sterbeort Luthers)
🏔️  Harzvorland mit Wäldern, Hügeln und dem Süßen See
🏰  Kyffhäuser, Schloss Stolberg, historische Städte
👨‍👩‍👧 Bodenständige, herzliche, heimatverbundene Menschen
═══════════════════════════════════════════════════════════════
```

### Design-Entscheidungen (bereits getroffen)

1. **Primärfarbe:** Kupfer (Bergbau-Erbe)
2. **Logo:** Regionaler gestalten (mit Harz/Bergbau-Bezug)
3. **Marker:** Abgerundete Quadrate statt Kreise
4. **"Keine Cookies" Badge:** Behalten, klein
5. **KOLAN Systems:** Nur im Footer
6. **Dunkel-Modus:** Bereits eingebaut, anpassen

---

## TEIL 1: Farbpalette implementieren

### 1.1 MshColors Klasse erstellen

Erstelle `lib/src/core/theme/msh_colors.dart`:

```dart
import 'package:flutter/material.dart';

/// Regionale Farbpalette für MSH Map
/// Inspiriert von Mansfeld-Südharz: Kupfer, Harz, Rosen
class MshColors {
  MshColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMÄR - Kupfer (Mansfelder Bergbau-Erbe)
  // ═══════════════════════════════════════════════════════════════
  
  /// Haupt-Kupferfarbe - für primäre Aktionen, aktive Elemente
  static const Color copper = Color(0xFFA65D3F);
  
  /// Heller Kupferton - für Hover-States
  static const Color copperLight = Color(0xFFBF7D5F);
  
  /// Dunkler Kupferton - für Pressed-States
  static const Color copperDark = Color(0xFF8B4D33);
  
  /// Kupfer-Oberfläche - sehr heller Hintergrund
  static const Color copperSurface = Color(0xFFFDF5F0);
  
  /// Kupfer transparent - für Overlays
  static Color copperOverlay = copper.withOpacity(0.1);

  // ═══════════════════════════════════════════════════════════════
  // SEKUNDÄR - Harz-Grün (Natur & Wälder)
  // ═══════════════════════════════════════════════════════════════
  
  /// Haupt-Grün - Wälder des Harzvorlandes
  static const Color forest = Color(0xFF4A6741);
  
  /// Helles Waldgrün
  static const Color forestLight = Color(0xFF6B8761);
  
  /// Dunkles Waldgrün
  static const Color forestDark = Color(0xFF3A5234);
  
  /// Grün-Oberfläche
  static const Color forestSurface = Color(0xFFF2F5F0);

  // ═══════════════════════════════════════════════════════════════
  // AKZENT - Rosen-Rot (Europa-Rosarium)
  // ═══════════════════════════════════════════════════════════════
  
  /// Rosen-Rot - für Highlights, Events, Herz
  static const Color rose = Color(0xFFC45C5C);
  
  /// Helles Rosenrot
  static const Color roseLight = Color(0xFFD88080);
  
  /// Dunkles Rosenrot
  static const Color roseDark = Color(0xFFA54545);
  
  /// Rosen-Oberfläche
  static const Color roseSurface = Color(0xFFFDF2F2);

  // ═══════════════════════════════════════════════════════════════
  // NEUTRAL - Schiefer (Kupferschiefer-Bergbau)
  // ═══════════════════════════════════════════════════════════════
  
  /// Schiefer-Grau - für Text und UI-Elemente
  static const Color slate = Color(0xFF5D6B7A);
  
  /// Heller Schiefer
  static const Color slateLight = Color(0xFF8A9AA8);
  
  /// Dunkler Schiefer
  static const Color slateDark = Color(0xFF3D4A56);
  
  /// Gedämpfter Schiefer
  static const Color slateMuted = Color(0xFF9EAAB6);

  // ═══════════════════════════════════════════════════════════════
  // REGIONALE AKZENTE
  // ═══════════════════════════════════════════════════════════════
  
  /// Gold - Goldene Aue, Ernte, Wärme
  static const Color golden = Color(0xFFD4A853);
  
  /// See-Blau - Süßer See, Wasser, Frische
  static const Color lake = Color(0xFF5B8FA8);
  
  /// Luther-Blau - Reformation, Geschichte
  static const Color luther = Color(0xFF3D5A80);
  
  /// Erde-Braun - Felder, Natur
  static const Color earth = Color(0xFF8B7355);

  // ═══════════════════════════════════════════════════════════════
  // HINTERGRÜNDE - Warm statt kalt
  // ═══════════════════════════════════════════════════════════════
  
  /// Haupt-Hintergrund - warmes Creme statt kaltem Weiß
  static const Color background = Color(0xFFFAF8F5);
  
  /// Oberflächen (Cards) - reines Weiß für Kontrast
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Oberflächen-Variante - leichte Trennung
  static const Color surfaceVariant = Color(0xFFEDEAE5);
  
  /// Erhöhte Oberfläche (Modals, Dialoge)
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE - Schiefer-Töne
  // ═══════════════════════════════════════════════════════════════
  
  /// Dark Hintergrund
  static const Color darkBackground = Color(0xFF1A1D21);
  
  /// Dark Oberfläche
  static const Color darkSurface = Color(0xFF252A30);
  
  /// Dark Oberflächen-Variante
  static const Color darkSurfaceVariant = Color(0xFF2F353D);
  
  /// Dark erhöhte Oberfläche
  static const Color darkSurfaceElevated = Color(0xFF363D47);

  // ═══════════════════════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════════════════════
  
  /// Primärer Text - fast schwarz, warm
  static const Color textPrimary = Color(0xFF2D3436);
  
  /// Sekundärer Text - Schiefer
  static const Color textSecondary = Color(0xFF5D6B7A);
  
  /// Gedämpfter Text - für Hinweise
  static const Color textMuted = Color(0xFF9EAAB6);
  
  /// Text auf dunklem Hintergrund
  static const Color textOnDark = Color(0xFFF5F5F5);
  
  /// Text auf Kupfer
  static const Color textOnCopper = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // KATEGORIEN - Regional passende Farben
  // ═══════════════════════════════════════════════════════════════
  
  /// Spielplätze - lebhaft, kindgerecht
  static const Color categoryPlayground = Color(0xFFE8A849);
  
  /// Museen - Kupfer (Bergbau-Geschichte)
  static const Color categoryMuseum = Color(0xFFA65D3F);
  
  /// Natur - Waldgrün
  static const Color categoryNature = Color(0xFF4A6741);
  
  /// Baden/Wasser - See-Blau
  static const Color categorySwimming = Color(0xFF5B8FA8);
  
  /// Burgen/Schlösser - historisches Gold
  static const Color categoryCastle = Color(0xFF8B6914);
  
  /// Zoo/Tiere - lebendiges Grün
  static const Color categoryZoo = Color(0xFF7B9F35);
  
  /// Bauernhof - Erde
  static const Color categoryFarm = Color(0xFF9B7B4D);
  
  /// Essen/Gastro - Rosen-Rot
  static const Color categoryFood = Color(0xFFC45C5C);
  
  /// Events - festliches Violett
  static const Color categoryEvent = Color(0xFF9B59B6);
  
  /// Kirchen/Luther - Luther-Blau
  static const Color categoryChurch = Color(0xFF3D5A80);
  
  /// Sport - aktives Grün
  static const Color categorySport = Color(0xFF27AE60);
  
  /// Aussichtspunkte - Himmelblau
  static const Color categoryViewpoint = Color(0xFF3498DB);

  // ═══════════════════════════════════════════════════════════════
  // SEMANTISCHE FARBEN
  // ═══════════════════════════════════════════════════════════════
  
  /// Erfolg - Waldgrün
  static const Color success = forest;
  
  /// Warnung - Golden
  static const Color warning = golden;
  
  /// Fehler - Rosen-Rot (sanfter als knallrot)
  static const Color error = rose;
  
  /// Info - See-Blau
  static const Color info = lake;

  // ═══════════════════════════════════════════════════════════════
  // KOLAN SYSTEMS CI (nur wo Firma erwähnt)
  // ═══════════════════════════════════════════════════════════════
  
  /// KOLAN Primär - Amber
  static const Color kolanPrimary = Color(0xFFFFB800);
  
  /// KOLAN Sekundär - Dark
  static const Color kolanSecondary = Color(0xFF1A1A2E);
  
  /// KOLAN Akzent
  static const Color kolanAccent = Color(0xFFFF6B00);

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════
  
  /// Gibt Kategorie-Farbe zurück
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'playground':
      case 'spielplatz':
        return categoryPlayground;
      case 'museum':
      case 'museen':
        return categoryMuseum;
      case 'nature':
      case 'natur':
        return categoryNature;
      case 'swimming':
      case 'baden':
      case 'pool':
      case 'lake':
      case 'see':
        return categorySwimming;
      case 'castle':
      case 'burg':
      case 'schloss':
      case 'burgen':
        return categoryCastle;
      case 'zoo':
      case 'tierpark':
        return categoryZoo;
      case 'farm':
      case 'bauernhof':
        return categoryFarm;
      case 'food':
      case 'essen':
      case 'restaurant':
      case 'gastro':
      case 'gastronomie':
        return categoryFood;
      case 'event':
      case 'events':
      case 'veranstaltung':
        return categoryEvent;
      case 'church':
      case 'kirche':
      case 'luther':
        return categoryChurch;
      case 'sport':
        return categorySport;
      case 'viewpoint':
      case 'aussicht':
        return categoryViewpoint;
      default:
        return copper;
    }
  }
  
  /// Schatten mit Kupferton (wärmer als grau)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: copper.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Stärkerer Schatten für erhöhte Elemente
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: copper.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
```

### 1.2 Theme erstellen

Erstelle `lib/src/core/theme/msh_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'msh_colors.dart';

class MshTheme {
  MshTheme._();

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════
  
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Farbschema
    colorScheme: const ColorScheme.light(
      primary: MshColors.copper,
      onPrimary: MshColors.textOnCopper,
      primaryContainer: MshColors.copperSurface,
      onPrimaryContainer: MshColors.copperDark,
      
      secondary: MshColors.forest,
      onSecondary: Colors.white,
      secondaryContainer: MshColors.forestSurface,
      onSecondaryContainer: MshColors.forestDark,
      
      tertiary: MshColors.rose,
      onTertiary: Colors.white,
      tertiaryContainer: MshColors.roseSurface,
      onTertiaryContainer: MshColors.roseDark,
      
      error: MshColors.error,
      onError: Colors.white,
      errorContainer: MshColors.roseSurface,
      onErrorContainer: MshColors.roseDark,
      
      background: MshColors.background,
      onBackground: MshColors.textPrimary,
      
      surface: MshColors.surface,
      onSurface: MshColors.textPrimary,
      surfaceVariant: MshColors.surfaceVariant,
      onSurfaceVariant: MshColors.textSecondary,
      
      outline: MshColors.slateLight,
      outlineVariant: MshColors.surfaceVariant,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: MshColors.background,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: MshColors.copper,
      foregroundColor: MshColors.textOnCopper,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: MshColors.textOnCopper,
      ),
    ),
    
    // Cards
    cardTheme: CardTheme(
      color: MshColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: MshColors.copper.withOpacity(0.1),
    ),
    
    // Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MshColors.copper,
        foregroundColor: MshColors.textOnCopper,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    
    // Outlined Buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MshColors.copper,
        side: const BorderSide(color: MshColors.copper, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    
    // Text Buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MshColors.copper,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MshColors.copper,
      foregroundColor: MshColors.textOnCopper,
      elevation: 4,
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: MshColors.surface,
      selectedColor: MshColors.copper,
      disabledColor: MshColors.surfaceVariant,
      labelStyle: const TextStyle(
        color: MshColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: MshColors.textOnCopper,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: MshColors.copper, width: 1),
      ),
    ),
    
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MshColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MshColors.slateLight.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MshColors.slateLight.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: MshColors.copper, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: MshColors.textMuted),
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: MshColors.surfaceVariant,
      thickness: 1,
      space: 1,
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MshColors.surface,
      selectedItemColor: MshColors.copper,
      unselectedItemColor: MshColors.slateMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Navigation Rail
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: MshColors.surface,
      selectedIconTheme: IconThemeData(color: MshColors.copper),
      unselectedIconTheme: IconThemeData(color: MshColors.slateMuted),
      selectedLabelTextStyle: TextStyle(
        color: MshColors.copper,
        fontWeight: FontWeight.w600,
      ),
      indicatorColor: MshColors.copperSurface,
    ),
    
    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: MshColors.surface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MshColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MshColors.slateDark,
      contentTextStyle: const TextStyle(color: MshColors.textOnDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MshColors.copper,
      linearTrackColor: MshColors.copperSurface,
    ),
    
    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return MshColors.copper;
        }
        return MshColors.slateLight;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return MshColors.copperLight;
        }
        return MshColors.surfaceVariant;
      }),
    ),
    
    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return MshColors.copper;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(MshColors.textOnCopper),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // Radio
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return MshColors.copper;
        }
        return MshColors.slateLight;
      }),
    ),
    
    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: MshColors.slateDark,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: MshColors.textOnDark,
        fontSize: 13,
      ),
    ),
    
    // Text Theme
    textTheme: _textTheme,
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: MshColors.slate,
      size: 24,
    ),
    
    // Primary Icon Theme
    primaryIconTheme: const IconThemeData(
      color: MshColors.textOnCopper,
      size: 24,
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════
  
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Farbschema
    colorScheme: ColorScheme.dark(
      primary: MshColors.copperLight,
      onPrimary: MshColors.darkBackground,
      primaryContainer: MshColors.copperDark,
      onPrimaryContainer: MshColors.copperLight,
      
      secondary: MshColors.forestLight,
      onSecondary: MshColors.darkBackground,
      secondaryContainer: MshColors.forestDark,
      onSecondaryContainer: MshColors.forestLight,
      
      tertiary: MshColors.roseLight,
      onTertiary: MshColors.darkBackground,
      tertiaryContainer: MshColors.roseDark,
      onTertiaryContainer: MshColors.roseLight,
      
      error: MshColors.roseLight,
      onError: MshColors.darkBackground,
      
      background: MshColors.darkBackground,
      onBackground: MshColors.textOnDark,
      
      surface: MshColors.darkSurface,
      onSurface: MshColors.textOnDark,
      surfaceVariant: MshColors.darkSurfaceVariant,
      onSurfaceVariant: MshColors.slateLight,
      
      outline: MshColors.slate,
      outlineVariant: MshColors.darkSurfaceVariant,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: MshColors.darkBackground,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: MshColors.darkSurface,
      foregroundColor: MshColors.textOnDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: MshColors.textOnDark,
      ),
    ),
    
    // Cards
    cardTheme: CardTheme(
      color: MshColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Buttons - ähnlich wie light, aber mit angepassten Farben
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MshColors.copperLight,
        foregroundColor: MshColors.darkBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    
    // Text Theme
    textTheme: _textThemeDark,
    
    // Weitere Dark-Anpassungen...
  );

  // ═══════════════════════════════════════════════════════════════
  // TEXT THEMES
  // ═══════════════════════════════════════════════════════════════
  
  static const TextTheme _textTheme = TextTheme(
    // Display
    displayLarge: TextStyle(
      fontFamily: 'Merriweather',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: MshColors.textPrimary,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Merriweather',
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: MshColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Merriweather',
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: MshColors.textPrimary,
    ),
    
    // Headlines
    headlineLarge: TextStyle(
      fontFamily: 'Merriweather',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: MshColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Merriweather',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: MshColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Merriweather',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: MshColors.textPrimary,
    ),
    
    // Titles
    titleLarge: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: MshColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: MshColors.textPrimary,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: MshColors.textPrimary,
      letterSpacing: 0.1,
    ),
    
    // Body
    bodyLarge: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: MshColors.textPrimary,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: MshColors.textPrimary,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: MshColors.textSecondary,
      letterSpacing: 0.4,
    ),
    
    // Labels
    labelLarge: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: MshColors.textPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: MshColors.textSecondary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: MshColors.textMuted,
      letterSpacing: 0.5,
    ),
  );
  
  static TextTheme get _textThemeDark => _textTheme.apply(
    bodyColor: MshColors.textOnDark,
    displayColor: MshColors.textOnDark,
  );
}
```

---

## TEIL 2: Marker-Design (Abgerundete Quadrate)

### 2.1 Marker Widget erstellen

Erstelle `lib/src/shared/widgets/msh_marker.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';

/// Regionaler Marker für MSH Map
/// Abgerundete Quadrate statt Kreise
class MshMarker extends StatelessWidget {
  final String category;
  final IconData icon;
  final bool isSelected;
  final bool hasWarning;
  final bool isPopular;
  final double size;
  final VoidCallback? onTap;

  const MshMarker({
    super.key,
    required this.category,
    required this.icon,
    this.isSelected = false,
    this.hasWarning = false,
    this.isPopular = false,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = MshColors.getCategoryColor(category);
    final borderRadius = BorderRadius.circular(size * 0.25); // 25% Rundung
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hauptmarker
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.9),
              borderRadius: borderRadius,
              border: Border.all(
                color: isSelected ? MshColors.copper : Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: size * 0.5,
              ),
            ),
          ),
          
          // Popularity Badge (Feuer-Emoji)
          if (isPopular)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: MshColors.golden,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 10)),
                ),
              ),
            ),
          
          // Warning Badge
          if (hasWarning)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: MshColors.rose,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),
          
          // Zeiger unten (optional - für Kartenmarker)
          Positioned(
            bottom: -6,
            left: (size - 12) / 2,
            child: CustomPaint(
              size: const Size(12, 6),
              painter: _TrianglePainter(
                color: isSelected ? color : color.withOpacity(0.9),
                borderColor: isSelected ? MshColors.copper : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 2.2 Kategorie-Icons Mapping

Erstelle `lib/src/core/constants/category_icons.dart`:

```dart
import 'package:flutter/material.dart';

/// Kategorie-Icons für MSH Map
/// Regionale Symbole wo möglich
class CategoryIcons {
  CategoryIcons._();

  /// Icon für Kategorie
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      // Familienaktivitäten
      case 'playground':
      case 'spielplatz':
      case 'spielplätze':
        return Icons.toys_rounded; // Spielzeug
        
      case 'zoo':
      case 'tierpark':
        return Icons.pets_rounded; // Tiere
        
      case 'farm':
      case 'bauernhof':
        return Icons.agriculture_rounded; // Bauernhof
        
      // Kultur & Geschichte
      case 'museum':
      case 'museen':
        return Icons.account_balance_rounded; // Klassisches Gebäude (Bergbau-Museum)
        
      case 'castle':
      case 'burg':
      case 'schloss':
      case 'burgen':
        return Icons.castle_rounded; // Burg
        
      case 'church':
      case 'kirche':
      case 'luther':
        return Icons.church_rounded; // Kirche (Luther)
        
      case 'monument':
      case 'denkmal':
        return Icons.account_balance_rounded;
        
      // Natur
      case 'nature':
      case 'natur':
      case 'wald':
      case 'forest':
        return Icons.forest_rounded; // Wald/Harz
        
      case 'park':
      case 'garten':
      case 'rosarium':
        return Icons.local_florist_rounded; // Rose/Blume (Rosarium)
        
      case 'viewpoint':
      case 'aussicht':
      case 'aussichtspunkt':
        return Icons.landscape_rounded; // Landschaft
        
      case 'hiking':
      case 'wandern':
      case 'wanderweg':
        return Icons.hiking_rounded;
        
      // Wasser
      case 'swimming':
      case 'baden':
      case 'pool':
      case 'freibad':
      case 'hallenbad':
        return Icons.pool_rounded; // Schwimmbad
        
      case 'lake':
      case 'see':
      case 'badesee':
        return Icons.water_rounded; // Wasser (Süßer See)
        
      // Gastronomie
      case 'restaurant':
      case 'essen':
      case 'food':
        return Icons.restaurant_rounded;
        
      case 'cafe':
      case 'café':
        return Icons.local_cafe_rounded;
        
      case 'biergarten':
      case 'beer_garden':
        return Icons.sports_bar_rounded;
        
      case 'hotel':
      case 'unterkunft':
        return Icons.hotel_rounded;
        
      // Events & Freizeit
      case 'event':
      case 'events':
      case 'veranstaltung':
        return Icons.event_rounded;
        
      case 'theater':
      case 'kino':
        return Icons.theater_comedy_rounded;
        
      case 'concert':
      case 'konzert':
        return Icons.music_note_rounded;
        
      case 'market':
      case 'markt':
        return Icons.storefront_rounded;
        
      // Sport
      case 'sport':
      case 'sportplatz':
        return Icons.sports_soccer_rounded;
        
      case 'fitness':
        return Icons.fitness_center_rounded;
        
      case 'minigolf':
        return Icons.golf_course_rounded;
        
      // Bergbau (regional spezifisch)
      case 'mining':
      case 'bergbau':
      case 'bergwerk':
      case 'schacht':
        return Icons.hardware_rounded; // Werkzeug/Bergbau
        
      // Infrastruktur
      case 'parking':
      case 'parkplatz':
        return Icons.local_parking_rounded;
        
      case 'bus_stop':
      case 'bushaltestelle':
        return Icons.directions_bus_rounded;
        
      case 'train':
      case 'bahnhof':
        return Icons.train_rounded;
        
      case 'charging':
      case 'ladesäule':
        return Icons.ev_station_rounded;
        
      // Services
      case 'hospital':
      case 'krankenhaus':
        return Icons.local_hospital_rounded;
        
      case 'pharmacy':
      case 'apotheke':
        return Icons.local_pharmacy_rounded;
        
      case 'school':
      case 'schule':
        return Icons.school_rounded;
        
      case 'library':
      case 'bibliothek':
        return Icons.local_library_rounded;
        
      // Default
      default:
        return Icons.location_on_rounded;
    }
  }

  /// Emoji für Kategorie (für Badges, Listen)
  static String getEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'playground':
      case 'spielplatz':
        return '🎠';
      case 'museum':
      case 'museen':
        return '🏛️';
      case 'nature':
      case 'natur':
        return '🌲';
      case 'swimming':
      case 'baden':
        return '🏊';
      case 'lake':
      case 'see':
        return '💧';
      case 'castle':
      case 'burg':
        return '🏰';
      case 'zoo':
      case 'tierpark':
        return '🦁';
      case 'farm':
      case 'bauernhof':
        return '🚜';
      case 'restaurant':
      case 'essen':
        return '🍽️';
      case 'cafe':
        return '☕';
      case 'event':
        return '🎉';
      case 'church':
      case 'kirche':
        return '⛪';
      case 'park':
      case 'rosarium':
        return '🌹';
      case 'viewpoint':
        return '🏔️';
      case 'hiking':
        return '🥾';
      case 'mining':
      case 'bergbau':
        return '⛏️';
      default:
        return '📍';
    }
  }

  /// Label für Kategorie (deutsch)
  static String getLabel(String category) {
    switch (category.toLowerCase()) {
      case 'playground':
        return 'Spielplätze';
      case 'museum':
        return 'Museen';
      case 'nature':
        return 'Natur';
      case 'swimming':
      case 'pool':
        return 'Baden';
      case 'lake':
        return 'Seen';
      case 'castle':
        return 'Burgen';
      case 'zoo':
        return 'Zoo';
      case 'farm':
        return 'Bauernhof';
      case 'restaurant':
      case 'food':
        return 'Essen';
      case 'cafe':
        return 'Café';
      case 'event':
        return 'Events';
      case 'church':
        return 'Kirchen';
      case 'park':
        return 'Parks';
      case 'viewpoint':
        return 'Aussicht';
      case 'hiking':
        return 'Wandern';
      case 'mining':
        return 'Bergbau';
      default:
        return category;
    }
  }
}
```

---

## TEIL 3: Filter-Chips im neuen Design

### 3.1 MshFilterChip Widget

Erstelle `lib/src/shared/widgets/msh_filter_chip.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/constants/category_icons.dart';

/// Filter-Chip im MSH Design
/// Kupfer-Akzent, abgerundete Form
class MshFilterChip extends StatelessWidget {
  final String label;
  final String? category;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showIcon;
  final bool showEmoji;

  const MshFilterChip({
    super.key,
    required this.label,
    this.category,
    this.count,
    required this.isSelected,
    required this.onTap,
    this.showIcon = true,
    this.showEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = category != null 
        ? MshColors.getCategoryColor(category!)
        : MshColors.copper;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : MshColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? chipColor : chipColor.withOpacity(0.4),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon oder Emoji
              if (showEmoji && category != null) ...[
                Text(
                  CategoryIcons.getEmoji(category!),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ] else if (showIcon && category != null) ...[
                Icon(
                  CategoryIcons.getIcon(category!),
                  size: 18,
                  color: isSelected ? Colors.white : chipColor,
                ),
                const SizedBox(width: 6),
              ],
              
              // Label
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : MshColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              
              // Count Badge
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.25) 
                        : chipColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : chipColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontale Filter-Chip Leiste
class MshFilterChipBar extends StatelessWidget {
  final List<FilterChipData> chips;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final EdgeInsets padding;

  const MshFilterChipBar({
    super.key,
    required this.chips,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = chip.category == selectedCategory ||
              (chip.category == null && selectedCategory == null);
          
          return MshFilterChip(
            label: chip.label,
            category: chip.category,
            count: chip.count,
            isSelected: isSelected,
            showEmoji: chip.showEmoji,
            onTap: () => onCategorySelected(chip.category),
          );
        },
      ),
    );
  }
}

class FilterChipData {
  final String label;
  final String? category;
  final int? count;
  final bool showEmoji;

  const FilterChipData({
    required this.label,
    this.category,
    this.count,
    this.showEmoji = true,
  });
}
```

---

## TEIL 4: Sidebar/Navigation im neuen Design

### 4.1 MshSidebar Widget

Erstelle `lib/src/shared/widgets/msh_sidebar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/msh_colors.dart';

/// Sidebar im MSH Design
/// Warmes Creme, Kupfer-Akzente
class MshSidebar extends StatelessWidget {
  final String currentPath;

  const MshSidebar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: MshColors.surface,
      child: Column(
        children: [
          // Header mit Logo
          _SidebarHeader(),
          
          const Divider(height: 1),
          
          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.map_rounded,
                  label: 'Karte',
                  path: '/',
                  isActive: currentPath == '/',
                ),
                _NavItem(
                  icon: Icons.family_restroom_rounded,
                  label: 'Familienaktivitäten',
                  path: '/family',
                  isActive: currentPath == '/family',
                ),
                _NavItem(
                  icon: Icons.restaurant_rounded,
                  label: 'Gastronomie',
                  path: '/gastro',
                  isActive: currentPath == '/gastro',
                ),
                _NavItem(
                  icon: Icons.event_rounded,
                  label: 'Veranstaltungen',
                  path: '/events',
                  isActive: currentPath == '/events',
                ),
                
                const SizedBox(height: 16),
                const Divider(indent: 16, endIndent: 16),
                const SizedBox(height: 8),
                
                _NavItem(
                  icon: Icons.info_outline_rounded,
                  label: 'Über MSH Map',
                  path: '/about',
                  isActive: currentPath == '/about',
                ),
                _NavItem(
                  icon: Icons.login_rounded,
                  label: 'Anmelden',
                  path: '/login',
                  isActive: currentPath == '/login',
                ),
              ],
            ),
          ),
          
          // Footer
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MshColors.copper,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Harz-Silhouette angedeutet
                const Center(
                  child: Icon(
                    Icons.landscape_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                // Kleine Bergbau-Andeutung
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: MshColors.golden,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Center(
                      child: Text(
                        '⛏',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MSH Map',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MshColors.textPrimary,
                  ),
                ),
                Text(
                  'Mansfeld-Südharz',
                  style: TextStyle(
                    fontSize: 12,
                    color: MshColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? MshColors.copperSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: BorderRadius.circular(10),
          hoverColor: MshColors.copperSurface.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? MshColors.copper : MshColors.slate,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? MshColors.copper : MshColors.textPrimary,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: MshColors.copper,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: MshColors.surfaceVariant),
        ),
      ),
      child: Column(
        children: [
          // Keine Cookies Badge (klein)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: MshColors.forestSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MshColors.forest.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🍪', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Icon(Icons.close, size: 12, color: MshColors.forest),
                const SizedBox(width: 4),
                Text(
                  'Keine Cookies',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MshColors.forest,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // KOLAN Systems - dezent
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: MshColors.kolanPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 10,
                  color: MshColors.kolanSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'KOLAN Systems',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: MshColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## TEIL 5: Cards im neuen Design

### 5.1 MshCard Widget

Erstelle `lib/src/shared/widgets/msh_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';

/// Card im MSH Design
/// Warmer Schatten, dezenter Kupfer-Akzent
class MshCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool showAccentBorder;
  final double borderRadius;

  const MshCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.accentColor,
    this.showAccentBorder = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? MshColors.copper;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showAccentBorder
            ? Border(
                left: BorderSide(color: color, width: 3),
              )
            : null,
        boxShadow: MshColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: MshColors.copperSurface.withOpacity(0.3),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Location Card für Listen
class MshLocationCard extends StatelessWidget {
  final String name;
  final String? description;
  final String category;
  final String? city;
  final int? popularityScore;
  final bool hasWarning;
  final VoidCallback? onTap;

  const MshLocationCard({
    super.key,
    required this.name,
    this.description,
    required this.category,
    this.city,
    this.popularityScore,
    this.hasWarning = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = MshColors.getCategoryColor(category);
    
    return MshCard(
      onTap: onTap,
      showAccentBorder: true,
      accentColor: color,
      child: Row(
        children: [
          // Kategorie-Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                CategoryIcons.getEmoji(category),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Badges
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (popularityScore != null && popularityScore! >= 70)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text('🔥', style: TextStyle(fontSize: 14)),
                      ),
                    if (hasWarning)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 16,
                          color: MshColors.rose,
                        ),
                      ),
                  ],
                ),
                
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: MshColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                if (city != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: MshColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        city!,
                        style: TextStyle(
                          fontSize: 12,
                          color: MshColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Chevron
          Icon(
            Icons.chevron_right_rounded,
            color: MshColors.slateMuted,
          ),
        ],
      ),
    );
  }
}
```

---

## TEIL 6: Schriften einbinden

### 6.1 pubspec.yaml

Füge die Schriften hinzu:

```yaml
flutter:
  fonts:
    - family: Merriweather
      fonts:
        - asset: assets/fonts/Merriweather-Regular.ttf
        - asset: assets/fonts/Merriweather-Bold.ttf
          weight: 700
        - asset: assets/fonts/Merriweather-Light.ttf
          weight: 300
          
    - family: Source Sans Pro
      fonts:
        - asset: assets/fonts/SourceSansPro-Regular.ttf
        - asset: assets/fonts/SourceSansPro-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/SourceSansPro-Bold.ttf
          weight: 700
        - asset: assets/fonts/SourceSansPro-Light.ttf
          weight: 300
```

### 6.2 Schriften herunterladen

```bash
# Im Projektordner
mkdir -p assets/fonts

# Google Fonts herunterladen (oder manuell von fonts.google.com)
# Merriweather: https://fonts.google.com/specimen/Merriweather
# Source Sans Pro: https://fonts.google.com/specimen/Source+Sans+Pro
```

---

## TEIL 7: Theme in App einbinden

### 7.1 main.dart anpassen

```dart
import 'package:flutter/material.dart';
import 'src/core/theme/msh_theme.dart';

void main() {
  runApp(const MshMapApp());
}

class MshMapApp extends StatelessWidget {
  const MshMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MSH Map - Mansfeld-Südharz',
      debugShowCheckedModeBanner: false,
      
      // Themes
      theme: MshTheme.light,
      darkTheme: MshTheme.dark,
      themeMode: ThemeMode.system, // Oder: ThemeMode.light
      
      // Router...
      routerConfig: appRouter,
    );
  }
}
```

---

## TEIL 8: Bestehende Komponenten migrieren

### 8.1 Checkliste

Gehe durch alle Screens und ersetze:

```
ERSETZEN                              DURCH
─────────────────────────────────────────────────────────────
Colors.orange                    →    MshColors.copper
Colors.blue                      →    MshColors.lake oder .forest
Colors.red                       →    MshColors.rose
Colors.grey                      →    MshColors.slate / .slateMuted
Colors.white (Hintergrund)       →    MshColors.background
Colors.white (Cards)             →    MshColors.surface

Theme.of(context).primaryColor   →    MshColors.copper
Theme.of(context).colorScheme... →    Entsprechende MshColors

CircleAvatar (Marker)            →    MshMarker
FilterChip                       →    MshFilterChip
Card                             →    MshCard

"Events"                         →    "Veranstaltungen"
"Locations"                      →    "Orte"
"Loading..."                     →    "Wird geladen..."
```

### 8.2 Alle Dateien durchgehen

```bash
# Suche nach alten Farben
grep -r "Colors.orange" lib/
grep -r "Colors.blue" lib/
grep -r "0xFF[0-9A-F]" lib/  # Hex-Farben

# Suche nach englischen Begriffen
grep -r '"Events"' lib/
grep -r '"Loading"' lib/
```

---

## TEIL 9: Testen

### 9.1 Visuelle Tests

```
[ ] Light Theme sieht warm und einladend aus
[ ] Dark Theme funktioniert mit Kupfer-Akzenten
[ ] Alle Kategorien haben passende Farben
[ ] Marker sind als abgerundete Quadrate erkennbar
[ ] Filter-Chips haben Kupfer-Akzent wenn aktiv
[ ] Sidebar hat warmes Creme, nicht kaltes Weiß
[ ] KOLAN Logo nur im Footer (klein)
[ ] "Keine Cookies" Badge klein aber sichtbar
[ ] Schatten sind warm (Kupferton), nicht grau
[ ] Schriften laden korrekt
```

### 9.2 Konsistenz

```
[ ] Alle Buttons haben gleichen Stil
[ ] Alle Cards haben gleichen Schatten
[ ] Abstände sind konsistent
[ ] Farben werden aus MshColors verwendet (keine hardcoded)
```

---

## Abschluss

Nach Fertigstellung:
- [ ] MshColors erstellt mit allen Farben
- [ ] MshTheme mit Light und Dark Mode
- [ ] MshMarker als abgerundete Quadrate
- [ ] CategoryIcons mit allen Kategorien
- [ ] MshFilterChip und MshFilterChipBar
- [ ] MshSidebar mit Logo und Footer
- [ ] MshCard und MshLocationCard
- [ ] Schriften eingebunden (Merriweather, Source Sans Pro)
- [ ] Alte Farben/Komponenten ersetzt
- [ ] Englische Begriffe eingedeutscht
- [ ] App startet ohne Fehler
- [ ] Design fühlt sich "heimatlich" an

Zeige mir Screenshots oder eine Zusammenfassung der Änderungen.
