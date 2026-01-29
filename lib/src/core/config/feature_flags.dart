/// Feature-Flags für MSH Map
///
/// Hier können Features ein/ausgeschaltet werden ohne UI-Änderungen.
/// true = Feature aktiv, false = Feature versteckt
class FeatureFlags {
  FeatureFlags._(); // Keine Instanzierung

  // ═══════════════════════════════════════════════════════════════
  // CORE FEATURES
  // ═══════════════════════════════════════════════════════════════

  /// Interaktive Karte mit Markern
  static const bool enableMap = true;

  /// Fog of War Effekt am Kartenrand (außerhalb MSH)
  static const bool enableFogOfWar = false;

  /// Kategorien-Filter auf der Karte
  static const bool enableCategoryFilter = true;

  /// Suchfunktion
  static const bool enableSearch = true;

  // ═══════════════════════════════════════════════════════════════
  // FAMILY FEATURES
  // ═══════════════════════════════════════════════════════════════

  /// Altersgerechte Empfehlungen (Kinder-Alter Filter)
  static const bool enableAgeFilter = true;

  /// Wetter-Integration mit Indoor/Outdoor Empfehlungen
  static const bool enableWeather = true;

  /// "Perfekt für deine Familie" Badges
  static const bool enableFamilyBadges = true;

  // ═══════════════════════════════════════════════════════════════
  // EVENTS & AKTUALITÄT
  // ═══════════════════════════════════════════════════════════════

  /// Veranstaltungen auf der Karte anzeigen
  static const bool enableEventsOnMap = true;

  /// "Diese Woche" Events Widget auf Startseite
  static const bool enableEventsWidget = true;

  /// Hinweise/Warnungen Banner (Sperrungen, etc.)
  static const bool enableNoticesBanner = true;

  /// Prognose "Wird es voll?"
  static const bool enableCrowdPrediction = false;

  // ═══════════════════════════════════════════════════════════════
  // MOBILITÄT
  // ═══════════════════════════════════════════════════════════════

  /// ÖPNV-Verbindungen Link bei Orten
  static const bool enablePublicTransport = true;

  /// E-Ladesäulen als Layer auf der Karte
  static const bool enableChargingStations = true;

  /// Offline-Karten Download
  static const bool enableOfflineMaps = false;

  // ═══════════════════════════════════════════════════════════════
  // KARTEN-LAYER
  // ═══════════════════════════════════════════════════════════════

  /// Naturschutzgebiete Layer
  static const bool enableNatureProtectionLayer = true;

  /// Heatmap-Ansicht (Beliebtheit)
  static const bool enableHeatmapLayer = false;

  /// Layer-Auswahl UI
  static const bool enableLayerSwitcher = true;

  // ═══════════════════════════════════════════════════════════════
  // COMMUNITY & FEEDBACK
  // ═══════════════════════════════════════════════════════════════

  /// "Fehlt etwas?" - Ort vorschlagen
  static const bool enableSuggestLocation = true;

  /// "Problem melden" - Gefahren/Issues melden
  static const bool enableReportIssue = true;

  /// Anonyme Bewertungen (1-5 Sterne)
  static const bool enableRatings = false;

  /// "Ich war da" Check-ins
  static const bool enableCheckIns = false;

  /// Foto-Uploads von Nutzern
  static const bool enablePhotoUploads = false;

  // ═══════════════════════════════════════════════════════════════
  // SOZIALES ENGAGEMENT
  // ═══════════════════════════════════════════════════════════════

  /// Zeigt Engagement-Orte (Tierheime, Vereine, etc.)
  static const bool enableEngagement = true;

  /// Zeigt Engagement-Orte auf der Karte
  static const bool enableEngagementOnMap = true;

  /// Zeigt spezielle Marker für dringende Hilfsaufrufe
  static const bool enableUrgentMarkers = true;

  /// Zeigt adoptierbare Tiere
  static const bool enableAdoptableAnimals = true;

  /// Zeigt Engagement-Widget auf Home
  static const bool enableEngagementWidget = true;

  /// Pulsierender Effekt für dringende Marker
  static const bool enablePulsingMarkers = true;

  // ═══════════════════════════════════════════════════════════════
  // MARKTPLATZ
  // ═══════════════════════════════════════════════════════════════

  /// Flohmarkt/Marketplace Modul
  static const bool enableMarketplace = true;

  /// Eigene Anzeige erstellen (sonst nur ansehen)
  static const bool enableMarketplaceCreate = true;

  // ═══════════════════════════════════════════════════════════════
  // DASHBOARD & ANALYTICS
  // ═══════════════════════════════════════════════════════════════

  /// "MSH in Zahlen" Dashboard
  static const bool enableDashboard = false;

  /// Infrastruktur-Lücken anzeigen
  static const bool enableGapAnalysis = false;

  /// Automatische Insights
  static const bool enableInsights = false;

  // ═══════════════════════════════════════════════════════════════
  // DEVELOPMENT & DEBUG
  // ═══════════════════════════════════════════════════════════════

  /// Debug-Overlay mit Extra-Infos
  static const bool enableDebugMode = false;

  /// Beta-Banner anzeigen
  static const bool showBetaBanner = false;

  /// Mock-Daten statt Firebase verwenden
  static const bool useMockData = false;
}
