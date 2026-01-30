/// Zentrale Texte für die MSH Map App.
/// Alle User-facing Strings an einem Ort für einfache Pflege.
class AppStrings {
  AppStrings._();

  // ═══════════════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════════════

  static const String appName = 'MSH Map';
  static const String appTagline = 'Mansfeld-Südharz entdecken';
  static const String appDescription =
      'Dein digitaler Begleiter für Familienausflüge, '
      'Gastronomie und Events in der Region Mansfeld-Südharz.';

  // ═══════════════════════════════════════════════════════════════
  // BRANDING
  // ═══════════════════════════════════════════════════════════════

  static const String poweredBy = 'Powered by';
  static const String companyName = 'KOLAN Systems';
  static const String companyOwner = 'Inh. Konstantin Lange';
  static const String companyUrl = 'https://kolan-systems.de';

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  static const String navExplore = 'Entdecken';
  static const String navFamily = 'Familienaktivitäten';
  static const String navGastro = 'Gastronomie';
  static const String navEvents = 'Veranstaltungen';
  static const String navSearch = 'Suche';
  static const String navAbout = 'Über MSH Map';
  static const String navPrivacy = 'Datenschutz';
  static const String navFeedback = 'Feedback';
  static const String navSuggest = 'Ort vorschlagen';

  // ═══════════════════════════════════════════════════════════════
  // KATEGORIEN
  // ═══════════════════════════════════════════════════════════════

  static const Map<String, String> categoryNames = {
    'playground': 'Spielplatz',
    'museum': 'Museum',
    'nature': 'Natur & Parks',
    'zoo': 'Tierpark',
    'indoor': 'Indoor-Aktivitäten',
    'pool': 'Baden & Schwimmen',
    'castle': 'Burg & Schloss',
    'farm': 'Bauernhof',
    'adventure': 'Abenteuer',
    'restaurant': 'Restaurant',
    'cafe': 'Café',
    'imbiss': 'Imbiss',
    'bar': 'Bar',
    'event': 'Veranstaltung',
    'other': 'Sonstiges',
  };

  static String getCategoryName(String key) =>
      categoryNames[key] ?? categoryNames['other']!;

  // ═══════════════════════════════════════════════════════════════
  // ALTERSGRUPPEN
  // ═══════════════════════════════════════════════════════════════

  static const Map<String, String> ageRanges = {
    '0-3': 'Für Kleinkinder (0-3 Jahre)',
    '3-6': 'Für Kindergartenkinder (3-6 Jahre)',
    '6-12': 'Für Grundschulkinder (6-12 Jahre)',
    '12+': 'Für Jugendliche (12+ Jahre)',
    'alle': 'Für alle Altersgruppen',
  };

  static String getAgeRange(String? key) =>
      key != null ? (ageRanges[key] ?? ageRanges['alle']!) : ageRanges['alle']!;

  // ═══════════════════════════════════════════════════════════════
  // FILTER & TAGS
  // ═══════════════════════════════════════════════════════════════

  static const String filterAll = 'Alle';
  static const String filterFree = 'Kostenlos';
  static const String filterOutdoor = 'Draußen';
  static const String filterIndoor = 'Drinnen';
  static const String filterBarrierFree = 'Barrierefrei';
  static const String filterOpenNow = 'Jetzt geöffnet';
  static const String filterNearby = 'In der Nähe';

  // ═══════════════════════════════════════════════════════════════
  // SUCHE
  // ═══════════════════════════════════════════════════════════════

  static const String searchHint = 'In MSH suchen...';
  static const String searchNoResults = 'Keine Ergebnisse gefunden';
  static const String searchTryAgain = 'Versuche es mit anderen Suchbegriffen';

  // ═══════════════════════════════════════════════════════════════
  // DETAILS
  // ═══════════════════════════════════════════════════════════════

  static const String detailAddress = 'Adresse';
  static const String detailOpeningHours = 'Öffnungszeiten';
  static const String detailContact = 'Kontakt';
  static const String detailWebsite = 'Website';
  static const String detailPhone = 'Telefon';
  static const String detailEmail = 'E-Mail';
  static const String detailPrice = 'Preise';
  static const String detailFacilities = 'Ausstattung';
  static const String detailAgeRange = 'Altersempfehlung';

  static const String actionNavigate = 'Route';
  static const String actionCall = 'Anrufen';
  static const String actionShare = 'Teilen';
  static const String actionSave = 'Merken';

  // ═══════════════════════════════════════════════════════════════
  // EINRICHTUNGEN (Facilities)
  // ═══════════════════════════════════════════════════════════════

  static const Map<String, String> facilityNames = {
    'wc': 'WC vorhanden',
    'parking': 'Parkplatz',
    'changing_table': 'Wickelmöglichkeit',
    'cafe': 'Café/Kiosk',
    'barrier_free': 'Barrierefrei',
    'playground': 'Spielplatz',
    'picnic': 'Picknick-Bereich',
    'dogs_allowed': 'Hunde erlaubt',
    'stroller_friendly': 'Kinderwagen-geeignet',
  };

  // ═══════════════════════════════════════════════════════════════
  // ABOUT PAGE
  // ═══════════════════════════════════════════════════════════════

  static const String aboutTitle = 'Warum MSH Map?';

  static const String aboutIntro =
      'Diese Plattform ist aus einem ganz konkreten Bedarf heraus entstanden, '
      'den ich hier in der Region täglich erlebe.';

  static const String aboutMotivation =
      'Meine Motivation für dieses Projekt stützt sich auf drei wesentliche Säulen:';

  static const String aboutFatherTitle = 'Der Blick als Familienvater';
  static const String aboutFatherText =
      'Als Vater kenne ich die Herausforderung nur zu gut: Man möchte am '
      'Wochenende etwas mit den Kindern unternehmen, findet aber kaum gebündelte '
      'Informationen. Oft sind Angebote versteckt, Webseiten veraltet oder man '
      'ist auf Mundpropaganda angewiesen. Die MSH Map soll diese Lücke schließen '
      'und Familien das Leben erleichtern.';

  static const String aboutEfficiencyTitle = 'Effizienz statt Suchen';
  static const String aboutEfficiencyText =
      'Herkömmliche Suchmaschinen und lokale Zeitungen liefern oft nur '
      'fragmentierte Ergebnisse. Mein Ziel war es, einen zentralen Ort zu '
      'schaffen – eine „Single Source of Truth" – an dem man nicht lange suchen '
      'muss, sondern sofort findet, was die Region zu bieten hat.';

  static const String aboutRegionTitle = 'Stärkung der Region Mansfeld-Südharz';
  static const String aboutRegionText =
      'Ich bin überzeugt, dass unsere Region viel mehr zu bieten hat, als oft '
      'sichtbar ist. Ich wünsche mir, dass wir uns besser vernetzen, lokale '
      'Stärken sichtbar machen und Mansfeld-Südharz durch digitale Zusammenarbeit '
      'wieder an Strahlkraft gewinnt.';

  static const String aboutClosing =
      'Es geht darum, das Potenzial unserer Heimat voll auszuschöpfen und durch '
      'smarte Vernetzung das Leben und Arbeiten hier attraktiver zu gestalten.';

  static const String aboutPersonal =
      '– Auch wenn ich hier nicht aufgewachsen bin, ist es doch meine Heimat.';

  // ═══════════════════════════════════════════════════════════════
  // FEEDBACK & MITMACHEN
  // ═══════════════════════════════════════════════════════════════

  static const String suggestTitle = 'Ort vorschlagen';
  static const String suggestDescription =
      'Kennst du einen tollen Ort in der Region, der noch fehlt? '
      'Schlage ihn uns vor!';

  static const String feedbackTitle = 'Feedback geben';
  static const String feedbackDescription =
      'Deine Meinung ist uns wichtig! Hilf uns, MSH Map noch besser zu machen.';

  // ═══════════════════════════════════════════════════════════════
  // FEHLERMELDUNGEN
  // ═══════════════════════════════════════════════════════════════

  static const String errorGeneric = 'Ein Fehler ist aufgetreten';
  static const String errorNoInternet = 'Keine Internetverbindung';
  static const String errorLoadFailed = 'Laden fehlgeschlagen';
  static const String errorTryAgain = 'Erneut versuchen';
  static const String errorLocationDenied = 'Standortzugriff verweigert';
  static const String errorLocationDisabled = 'Standort ist deaktiviert';

  // ═══════════════════════════════════════════════════════════════
  // LEER-ZUSTÄNDE
  // ═══════════════════════════════════════════════════════════════

  static const String emptyFavorites = 'Noch keine Favoriten';
  static const String emptyFavoritesHint = 'Markiere Orte mit dem Herz-Symbol';
  static const String emptyNearby = 'Keine Orte in der Nähe';
  static const String emptyNearbyHint = 'Zoome heraus oder wähle andere Filter';

  // ═══════════════════════════════════════════════════════════════
  // AKTIONEN
  // ═══════════════════════════════════════════════════════════════

  static const String actionOk = 'OK';
  static const String actionCancel = 'Abbrechen';
  static const String actionClose = 'Schließen';
  static const String actionSend = 'Senden';
  static const String actionNext = 'Weiter';
  static const String actionBack = 'Zurück';
  static const String actionDone = 'Fertig';
}
