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

  // ═══════════════════════════════════════════════════════════════
  // STATUS
  // ═══════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
