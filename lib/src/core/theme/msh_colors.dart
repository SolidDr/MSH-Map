import 'package:flutter/material.dart';

class MshColors {
  MshColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMÄR: Warmes Amber (freundlich, einladend)
  // 4-Stufen Hierarchie für visuelle Tiefe
  // ═══════════════════════════════════════════════════════════════

  /// Level 1 - Stark (für wichtige Aktionen, Hover-States)
  static const Color primaryStrong = Color(0xFFD97706);    // Amber 600

  /// Level 2 - Normal (Standard-Primärfarbe)
  static const Color primary = Color(0xFFF59E0B);          // Amber 500

  /// Level 3 - Hell (für Akzente, ausgewählte States)
  static const Color primaryLight = Color(0xFFFBBF24);     // Amber 400

  /// Level 4 - Subtil (für Hintergründe, sehr leichte Akzente)
  static const Color primarySubtle = Color(0xFFFEF3C7);    // Amber 100

  // Legacy-Kompatibilität
  @Deprecated('Use primaryStrong instead')
  static const Color primaryDark = primaryStrong;
  @Deprecated('Use primarySubtle instead')
  static const Color primarySurface = primarySubtle;

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

  // ═══════════════════════════════════════════════════════════════
  // TEXT: 4-Stufen Hierarchie für bessere Lesbarkeit
  // ═══════════════════════════════════════════════════════════════

  /// Level 1 - Stark (für Headlines, wichtige Informationen)
  static const Color textStrong = Color(0xFF1C1917);      // Stone 900

  /// Level 2 - Primär (für Body-Text, Standard)
  static const Color textPrimary = Color(0xFF292524);     // Stone 800

  /// Level 3 - Sekundär (für Meta-Informationen, Timestamps)
  static const Color textSecondary = Color(0xFF78716C);   // Stone 500

  /// Level 4 - Gedämpft (für Disabled States, unwichtige Infos)
  static const Color textMuted = Color(0xFFA8A29E);       // Stone 400

  /// Text auf Primärfarbe (immer weiß)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // KATEGORIE-FARBEN (für Map-Marker)
  // ═══════════════════════════════════════════════════════════════

  static const Color categoryFamily = Color(0xFFF59E0B);     // Amber - Familie
  static const Color categoryNature = Color(0xFF4CAF50);     // Green - Natur
  static const Color categoryMuseum = Color(0xFF9C27B0);     // Purple - Museum
  static const Color categoryCastle = Color(0xFF795548);     // Brown - Burg/Schloss
  static const Color categoryPool = Color(0xFF2196F3);       // Blue - Schwimmbad
  static const Color categoryPlayground = Color(0xFFFF9800); // Orange - Spielplatz
  static const Color categoryZoo = Color(0xFF8BC34A);        // Light Green - Zoo
  static const Color categoryFarm = Color(0xFFFFC107);       // Amber - Bauernhof
  static const Color categoryAdventure = Color(0xFFF44336);  // Red - Abenteuer
  static const Color categoryGastro = Color(0xFFEF4444);     // Red - Gastro
  static const Color categoryEvent = Color(0xFF6366F1);      // Indigo - Event

  // Bildung
  static const Color categorySchool = Color(0xFF1976D2);        // Blau - Schulen
  static const Color categoryKindergarten = Color(0xFFEC407A);  // Pink - Kitas
  static const Color categoryLibrary = Color(0xFF00796B);       // Teal - Bibliotheken
  static const Color categoryEducation = Color(0xFF1976D2);     // Blau - Bildung allgemein

  // ═══════════════════════════════════════════════════════════════
  // GESUNDHEIT - Health & Fitness Modul
  // ═══════════════════════════════════════════════════════════════

  /// Hauptfarbe für Gesundheitsbereich
  static const Color categoryHealth = Color(0xFF4CAF50);        // Grün - Primary
  static const Color categoryDoctor = Color(0xFF2196F3);        // Blau - Ärzte
  static const Color categoryPharmacy = Color(0xFFE91E63);      // Pink - Apotheken
  static const Color categoryHospital = Color(0xFFF44336);      // Rot - Krankenhaus
  static const Color categoryPhysiotherapy = Color(0xFF9C27B0); // Lila - Physio
  static const Color categoryFitnessSenior = Color(0xFFFF9800); // Orange - Fitness
  static const Color categoryCareService = Color(0xFF00BCD4);   // Cyan - Pflege

  // Emergency Colors (hohe Sichtbarkeit für Senioren)
  static const Color emergencyRed = Color(0xFFD32F2F);          // 112 Notruf
  static const Color emergencyBlue = Color(0xFF1976D2);         // 116117 Bereitschaft
  static const Color emergencyGreen = Color(0xFF388E3C);        // Notdienst Apotheke
  static const Color emergencyPurple = Color(0xFF7B1FA2);       // Telefonseelsorge

  // ═══════════════════════════════════════════════════════════════
  // CIVIC - Behörden, Jugendzentren, Soziale Einrichtungen
  // ═══════════════════════════════════════════════════════════════

  static const Color categoryGovernment = Color(0xFF607D8B);    // Blaugrau - Behörden
  static const Color categoryYouthCentre = Color(0xFF8E24AA);   // Lila - Jugendzentren
  static const Color categorySocialFacility = Color(0xFF00897B);// Teal - Soziale Einrichtungen

  // ═══════════════════════════════════════════════════════════════
  // BEWERTUNGS-STERNE
  // ═══════════════════════════════════════════════════════════════

  static const Color starFilled = Color(0xFFFBBF24);     // Amber 400 - Gefüllter Stern
  static const Color starEmpty = Color(0xFFD6D3D1);      // Stone 300 - Leerer Stern

  // ═══════════════════════════════════════════════════════════════
  // ZUSÄTZLICHE FARBEN
  // ═══════════════════════════════════════════════════════════════

  static const Color forest = Color(0xFF2D5016);         // Dunkelgrün
  static const Color copper = Color(0xFFB87333);         // Kupfer
  static const Color copperSurface = Color(0xFFFFF0E5);  // Helles Kupfer
  static const Color slateMuted = Color(0xFF94A3B8);     // Gedämpftes Grau

  /// Standard Card Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // STATUS
  // ═══════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════════════════════════
  // ENGAGEMENT - Spezielle Farben für soziales Engagement
  // ═══════════════════════════════════════════════════════════════

  // Urgency-Levels (4-Stufen für visuelle Hierarchie)

  /// Level 1 - Kritisch (höchste Dringlichkeit, pulsierend)
  static const Color engagementCritical = Color(0xFFDC2626);   // Red 600

  /// Level 2 - Dringend (hohe Priorität)
  static const Color engagementUrgent = Color(0xFFEA580C);     // Orange 600

  /// Level 3 - Erhöht (mittlere Priorität)
  static const Color engagementElevated = Color(0xFFF59E0B);   // Amber 500

  /// Level 4 - Normal (Standard, alles ok)
  static const Color engagementNormal = Color(0xFF10B981);     // Green 500

  // Typ-Farben

  /// Engagement-Gold - für "Helfen"-Rahmen
  static const Color engagementGold = Color(0xFFD4A853);

  /// Engagement-Herz - für Adoption
  static const Color engagementHeart = Color(0xFFE74C3C);

  /// Tierheim-Braun
  static const Color engagementAnimal = Color(0xFF8B4513);

  /// Ehrenamt-Violett
  static const Color engagementVolunteer = Color(0xFF9B59B6);

  /// Sozial-Blau
  static const Color engagementSocial = Color(0xFF3498DB);

  /// Spenden-Grün
  static const Color engagementDonation = Color(0xFF27AE60);

  /// Gibt Engagement-Typ-Farbe zurück
  static Color getEngagementColor(String typeId) {
    switch (typeId) {
      case 'animal_shelter':
        return engagementAnimal;
      case 'volunteer':
        return engagementVolunteer;
      case 'help_needed':
        return engagementUrgent;
      case 'social_service':
        return engagementSocial;
      case 'donation':
        return engagementDonation;
      case 'blood_donation':
        return const Color(0xFFC0392B);
      case 'environment':
        return const Color(0xFF2ECC71);
      default:
        return engagementVolunteer;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE COLORS
  // ═══════════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF0F0E0E);        // Sehr dunkles Grau
  static const Color darkSurface = Color(0xFF1C1917);           // Stone 900
  static const Color darkSurfaceVariant = Color(0xFF292524);    // Stone 800
  static const Color darkSurfaceElevated = Color(0xFF2C2A29);   // Leicht erhöht

  static const Color darkTextPrimary = Color(0xFFFAFAF9);       // Stone 50
  static const Color darkTextSecondary = Color(0xFFA8A29E);     // Stone 400

  static const Color darkPrimary = Color(0xFFFBBF24);           // Amber 400 - heller für dark mode
  static const Color darkPrimaryLight = Color(0xFFFCD34D);      // Amber 300
  static const Color darkPrimaryDark = Color(0xFFF59E0B);       // Amber 500
  static const Color darkPrimarySurface = Color(0xFF451A03);    // Amber 950

  // ═══════════════════════════════════════════════════════════════
  // HIGH CONTRAST COLORS (für Accessibility)
  // ═══════════════════════════════════════════════════════════════

  static const Color highContrastPrimary = Color(0xFFFFD700);   // Gold
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastSurface = Color(0xFF1A1A1A);
  static const Color highContrastText = Color(0xFFFFFFFF);
  static const Color highContrastBorder = Color(0xFFFFD700);
}
