# Prompt 6: Gesundheit & Fitness Addon

## Übersicht

Neuer Bereich speziell für **ältere Bevölkerung** mit Fokus auf:
- Ärzte-Suche (mit Details)
- Notdienst-Apotheken
- Fitness/Bewegung für Senioren
- Integration in DeepSearch

---

## Zielgruppe

**Ältere Menschen (60+)** mit besonderen Anforderungen:
- Größere Schrift / gute Lesbarkeit
- Einfache Navigation
- Wichtige Infos sofort sichtbar (Telefon, Öffnungszeiten)
- Notfall-Informationen prominent
- Barrierefreiheit beachten

---

## Teil A: Datenstruktur

### 1. Ärzte / Praxen

```javascript
{
  id: "arzt_001",
  type: "doctor",
  category: "Gesundheit",
  subcategory: "Arzt",
  
  // Basis-Infos
  name: "Dr. med. Maria Schmidt",
  fachrichtung: "Allgemeinmedizin", // Hausarzt, Kardiologe, Orthopäde, etc.
  
  // Kontakt
  telefon: "03464 123456",
  telefon_display: "03464 / 12 34 56", // Formatiert für bessere Lesbarkeit
  fax: "03464 123457",
  email: "praxis@dr-schmidt.de",
  website: "https://dr-schmidt.de",
  
  // Adresse
  strasse: "Hauptstraße 15",
  plz: "06526",
  ort: "Sangerhausen",
  lat: 51.4721,
  lng: 11.2978,
  
  // Öffnungszeiten
  oeffnungszeiten: {
    montag: { von: "08:00", bis: "12:00", nachmittag: { von: "14:00", bis: "18:00" } },
    dienstag: { von: "08:00", bis: "12:00" },
    mittwoch: { von: "08:00", bis: "12:00", nachmittag: { von: "14:00", bis: "18:00" } },
    donnerstag: { von: "08:00", bis: "12:00" },
    freitag: { von: "08:00", bis: "12:00" },
    samstag: null,
    sonntag: null
  },
  
  // Zusatz-Infos
  sprechstunde_ohne_termin: "Di + Do 08:00-09:00",
  hausbesuche: true,
  barrierefrei: true,
  parkplaetze: true,
  sprachen: ["Deutsch", "Englisch"],
  
  // Kassenzulassung
  kassenpatient: true,
  privatpatient: true,
  
  // Bewertungen (falls vorhanden)
  bewertung: 4.3,
  bewertung_anzahl: 47
}
```

### 2. Apotheken (inkl. Notdienst)

```javascript
{
  id: "apotheke_001",
  type: "pharmacy",
  category: "Gesundheit",
  subcategory: "Apotheke",
  
  name: "Rats-Apotheke",
  
  // Kontakt
  telefon: "03464 234567",
  telefon_display: "03464 / 23 45 67",
  notdienst_telefon: "03464 234567", // Falls anders
  
  // Adresse
  strasse: "Marktplatz 3",
  plz: "06526",
  ort: "Sangerhausen",
  lat: 51.4725,
  lng: 11.2985,
  
  // Öffnungszeiten
  oeffnungszeiten: {
    montag: { von: "08:00", bis: "18:30" },
    dienstag: { von: "08:00", bis: "18:30" },
    mittwoch: { von: "08:00", bis: "18:30" },
    donnerstag: { von: "08:00", bis: "18:30" },
    freitag: { von: "08:00", bis: "18:30" },
    samstag: { von: "09:00", bis: "13:00" },
    sonntag: null
  },
  
  // NOTDIENST - Wichtig!
  notdienst: {
    aktiv: true, // Hat grundsätzlich Notdienst
    aktuell: false, // Ist JETZT im Notdienst
    naechster: "2025-01-28", // Nächster Notdienst-Tag
    notdienst_zeiten: "20:00 - 08:00" // Übliche Notdienst-Zeiten
  },
  
  // Services
  lieferservice: true,
  barrierefrei: true,
  parkplaetze: true
}
```

### 3. Fitness / Bewegung für Senioren

```javascript
{
  id: "fitness_001",
  type: "fitness",
  category: "Gesundheit",
  subcategory: "Fitness",
  
  name: "Seniorensport im Sportverein Sangerhausen",
  beschreibung: "Gymnastik und Bewegung für Senioren",
  
  // Angebot
  angebote: [
    {
      name: "Seniorengymnastik",
      tag: "Montag",
      zeit: "10:00 - 11:00",
      ort: "Sporthalle Am Rosengarten"
    },
    {
      name: "Wassergymnastik",
      tag: "Mittwoch", 
      zeit: "14:00 - 15:00",
      ort: "Hallenbad Sangerhausen"
    }
  ],
  
  // Kontakt
  telefon: "03464 345678",
  ansprechpartner: "Frau Müller",
  
  // Details
  kosten: "5€ pro Einheit / Vereinsmitglieder kostenlos",
  barrierefrei: true,
  keine_vorkenntnisse: true,
  altergruppe: "60+"
}
```

### 4. Weitere Gesundheits-Einrichtungen

```javascript
// Krankenhaus / Klinik
{
  type: "hospital",
  subcategory: "Krankenhaus",
  notaufnahme: true,
  notaufnahme_telefon: "03464 999000"
}

// Physiotherapie
{
  type: "physiotherapy",
  subcategory: "Physiotherapie",
  hausbesuche: true,
  rezept_erforderlich: true
}

// Pflegedienst
{
  type: "care_service",
  subcategory: "Pflegedienst",
  leistungen: ["Grundpflege", "Behandlungspflege", "Hauswirtschaft"]
}

// Sanitätshaus
{
  type: "medical_supply",
  subcategory: "Sanitätshaus",
  produkte: ["Rollstühle", "Gehhilfen", "Bandagen"]
}
```

---

## Teil B: UI-Komponenten

### 1. Neuer Tab "Gesundheit"

```html
<!-- In der Hauptnavigation -->
<nav class="main-tabs">
  <button data-tab="karte">Karte</button>
  <button data-tab="entdecken">Entdecken</button>
  <button data-tab="erleben">Erleben</button>
  <button data-tab="gesundheit" class="health-tab">
    <span class="tab-icon">🏥</span>
    <span class="tab-label">Gesundheit</span>
  </button>
  <button data-tab="mobilitaet">Mobilität</button>
</nav>
```

### 2. Gesundheit Hauptansicht

```html
<div class="health-view">
  
  <!-- NOTFALL-BEREICH - Immer oben, prominent -->
  <div class="emergency-section">
    <h2 class="emergency-title">🚨 Notfall</h2>
    <div class="emergency-buttons">
      <a href="tel:112" class="emergency-btn emergency-112">
        <span class="btn-number">112</span>
        <span class="btn-label">Notruf</span>
      </a>
      <a href="tel:116117" class="emergency-btn emergency-116117">
        <span class="btn-number">116 117</span>
        <span class="btn-label">Ärztlicher Bereitschaftsdienst</span>
      </a>
      <button class="emergency-btn emergency-pharmacy" onclick="showNotdienstApotheke()">
        <span class="btn-icon">💊</span>
        <span class="btn-label">Notdienst-Apotheke</span>
      </button>
    </div>
  </div>
  
  <!-- Such-/Filter-Bereich -->
  <div class="health-search">
    <input type="text" placeholder="Arzt, Apotheke, Physiotherapie..." class="health-search-input">
    
    <div class="health-filters">
      <button class="filter-btn active" data-filter="alle">Alle</button>
      <button class="filter-btn" data-filter="arzt">Ärzte</button>
      <button class="filter-btn" data-filter="apotheke">Apotheken</button>
      <button class="filter-btn" data-filter="physio">Physiotherapie</button>
      <button class="filter-btn" data-filter="fitness">Fitness</button>
      <button class="filter-btn" data-filter="pflege">Pflege</button>
    </div>
    
    <!-- Fachrichtung-Filter (nur bei Ärzte) -->
    <div class="speciality-filters hidden" id="speciality-filters">
      <select class="speciality-select">
        <option value="">Alle Fachrichtungen</option>
        <option value="allgemein">Allgemeinmedizin / Hausarzt</option>
        <option value="innere">Innere Medizin</option>
        <option value="kardio">Kardiologie</option>
        <option value="ortho">Orthopädie</option>
        <option value="neuro">Neurologie</option>
        <option value="augen">Augenheilkunde</option>
        <option value="hno">HNO</option>
        <option value="haut">Dermatologie</option>
        <option value="uro">Urologie</option>
        <option value="gyn">Gynäkologie</option>
        <option value="zahn">Zahnarzt</option>
      </select>
    </div>
    
    <!-- Zusatz-Filter -->
    <div class="extra-filters">
      <label class="checkbox-filter">
        <input type="checkbox" id="filter-open-now">
        <span>Jetzt geöffnet</span>
      </label>
      <label class="checkbox-filter">
        <input type="checkbox" id="filter-barrier-free">
        <span>Barrierefrei</span>
      </label>
      <label class="checkbox-filter">
        <input type="checkbox" id="filter-house-calls">
        <span>Hausbesuche</span>
      </label>
    </div>
  </div>
  
  <!-- Ergebnis-Liste -->
  <div class="health-results">
    <!-- Dynamisch gefüllt -->
  </div>
  
</div>
```

### 3. Arzt-Karte (Detail-Ansicht)

```html
<div class="doctor-card">
  <!-- Header -->
  <div class="doctor-header">
    <div class="doctor-info">
      <h3 class="doctor-name">Dr. med. Maria Schmidt</h3>
      <span class="doctor-speciality">Allgemeinmedizin</span>
    </div>
    <div class="doctor-rating" title="4.3 von 5 Sternen">
      <span class="stars">★★★★☆</span>
      <span class="rating-count">(47)</span>
    </div>
  </div>
  
  <!-- Kontakt - GROß und KLICKBAR -->
  <div class="doctor-contact">
    <a href="tel:03464123456" class="contact-btn contact-phone">
      <span class="contact-icon">📞</span>
      <span class="contact-value">03464 / 12 34 56</span>
    </a>
    <button class="contact-btn contact-route" onclick="showRoute(this)">
      <span class="contact-icon">🗺️</span>
      <span class="contact-value">Route anzeigen</span>
    </button>
  </div>
  
  <!-- Adresse -->
  <div class="doctor-address">
    <span class="address-icon">📍</span>
    <span class="address-text">Hauptstraße 15, 06526 Sangerhausen</span>
  </div>
  
  <!-- Öffnungszeiten -->
  <div class="doctor-hours">
    <div class="hours-header">
      <span class="hours-icon">🕐</span>
      <span class="hours-title">Öffnungszeiten</span>
      <span class="hours-status status-open">Jetzt geöffnet</span>
      <!-- oder -->
      <span class="hours-status status-closed">Geschlossen</span>
    </div>
    <table class="hours-table">
      <tr class="today">
        <td>Montag</td>
        <td>08:00 - 12:00, 14:00 - 18:00</td>
      </tr>
      <tr>
        <td>Dienstag</td>
        <td>08:00 - 12:00</td>
      </tr>
      <!-- ... -->
    </table>
  </div>
  
  <!-- Zusatz-Infos -->
  <div class="doctor-extras">
    <span class="extra-badge" title="Barrierefrei zugänglich">♿ Barrierefrei</span>
    <span class="extra-badge" title="Hausbesuche möglich">🏠 Hausbesuche</span>
    <span class="extra-badge" title="Parkplätze vorhanden">🅿️ Parkplätze</span>
  </div>
  
  <!-- Aktionen -->
  <div class="doctor-actions">
    <button class="action-btn" onclick="showOnMap(this)">Auf Karte zeigen</button>
    <button class="action-btn secondary" onclick="saveDoctor(this)">Merken</button>
  </div>
</div>
```

### 4. Notdienst-Apotheke Anzeige

```html
<div class="pharmacy-emergency-modal">
  <div class="modal-header">
    <h2>💊 Notdienst-Apotheke</h2>
    <span class="emergency-date">Heute, 27.01.2025</span>
  </div>
  
  <div class="pharmacy-on-duty">
    <h3 class="pharmacy-name">Rats-Apotheke</h3>
    <p class="pharmacy-address">Marktplatz 3, 06526 Sangerhausen</p>
    
    <a href="tel:03464234567" class="emergency-call-btn">
      <span class="call-icon">📞</span>
      <span class="call-number">03464 / 23 45 67</span>
      <span class="call-hint">Jetzt anrufen</span>
    </a>
    
    <div class="pharmacy-hours">
      <strong>Notdienst-Zeiten:</strong> 20:00 - 08:00 Uhr
    </div>
    
    <button class="route-btn" onclick="showRoute()">
      🗺️ Route anzeigen
    </button>
  </div>
  
  <div class="pharmacy-info">
    <p>💡 <strong>Tipp:</strong> Außerhalb der Öffnungszeiten klingeln Sie bitte an der Notdienstklingel.</p>
  </div>
  
  <!-- Nächste Notdienste -->
  <div class="upcoming-duties">
    <h4>Nächste Notdienste in der Region:</h4>
    <ul class="duty-list">
      <li>
        <span class="duty-date">Di, 28.01.</span>
        <span class="duty-pharmacy">Adler-Apotheke, Eisleben</span>
      </li>
      <li>
        <span class="duty-date">Mi, 29.01.</span>
        <span class="duty-pharmacy">Löwen-Apotheke, Sangerhausen</span>
      </li>
    </ul>
  </div>
</div>
```

---

## Teil C: CSS-Styling (Seniorenfreundlich)

```css
/* ===== GRUNDPRINZIPIEN FÜR SENIOREN ===== */

/* 1. Größere Basis-Schrift */
.health-view {
  font-size: 16px; /* Statt 14px */
  line-height: 1.6;
}

/* 2. Hoher Kontrast */
.health-view {
  --text-primary: #ffffff;
  --text-secondary: #cccccc;
  --bg-primary: #0a0a0d;
  --bg-secondary: #151518;
  --accent: #c9a227;
  --success: #4CAF50;
  --danger: #f44336;
}

/* 3. Große Touch-Targets */
.filter-btn,
.contact-btn,
.action-btn {
  min-height: 48px;
  min-width: 48px;
  padding: 12px 20px;
  font-size: 15px;
}

/* ===== NOTFALL-BEREICH ===== */
.emergency-section {
  background: linear-gradient(135deg, #1a0a0a 0%, #2a1010 100%);
  border: 2px solid #ff4444;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
}

.emergency-title {
  color: #ff6666;
  font-size: 20px;
  margin-bottom: 15px;
}

.emergency-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.emergency-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 15px 20px;
  border-radius: 10px;
  text-decoration: none;
  min-width: 100px;
  min-height: 70px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.emergency-btn:active {
  transform: scale(0.95);
}

.emergency-112 {
  background: #d32f2f;
  color: white;
}

.emergency-116117 {
  background: #1976d2;
  color: white;
}

.emergency-pharmacy {
  background: #388e3c;
  color: white;
  border: none;
  cursor: pointer;
}

.btn-number {
  font-size: 24px;
  font-weight: 700;
}

.btn-label {
  font-size: 11px;
  margin-top: 4px;
  text-align: center;
}

/* ===== ARZT-KARTE ===== */
.doctor-card {
  background: var(--bg-secondary);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 15px;
  border: 1px solid #2a2a2a;
}

.doctor-name {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0 0 4px 0;
}

.doctor-speciality {
  color: var(--accent);
  font-size: 14px;
}

/* Telefon-Button extra groß */
.contact-phone {
  background: var(--accent);
  color: #000;
  font-size: 18px;
  font-weight: 600;
  padding: 15px 25px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  margin: 15px 0;
}

.contact-phone:hover {
  background: #d4af37;
}

.contact-phone .contact-icon {
  font-size: 22px;
}

/* Öffnungszeiten-Tabelle */
.hours-table {
  width: 100%;
  font-size: 14px;
  border-collapse: collapse;
}

.hours-table td {
  padding: 8px 0;
  border-bottom: 1px solid #2a2a2a;
}

.hours-table tr.today {
  background: rgba(201, 162, 39, 0.1);
  font-weight: 600;
}

.hours-status {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 20px;
  margin-left: auto;
}

.status-open {
  background: #1b5e20;
  color: #a5d6a7;
}

.status-closed {
  background: #b71c1c;
  color: #ef9a9a;
}

/* Badges */
.extra-badge {
  display: inline-block;
  background: #2a2a2a;
  color: #aaa;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 13px;
  margin: 4px 4px 4px 0;
}

/* ===== MOBILE ANPASSUNGEN ===== */
@media (max-width: 768px) {
  .health-view {
    font-size: 17px; /* Noch größer auf Mobile */
  }
  
  .emergency-buttons {
    flex-direction: column;
  }
  
  .emergency-btn {
    width: 100%;
    flex-direction: row;
    justify-content: flex-start;
    gap: 15px;
    padding: 18px 20px;
  }
  
  .btn-number {
    font-size: 28px;
    min-width: 80px;
  }
  
  .btn-label {
    font-size: 14px;
    text-align: left;
  }
  
  .contact-phone {
    width: 100%;
    justify-content: center;
    font-size: 20px;
    padding: 18px;
  }
}
```

---

## Teil D: DeepSearch Integration

### Erweiterung der Suchquellen

```javascript
// In der DeepSearch-Konfiguration hinzufügen:

const HEALTH_SEARCH_SOURCES = [
  {
    name: "Arztsuche",
    type: "doctors",
    endpoints: [
      "https://www.jameda.de/",
      "https://www.doctolib.de/",
      "https://arzt-auskunft.de/",
      "https://www.weisse-liste.de/arzt"
    ],
    extractFields: ["name", "fachrichtung", "adresse", "telefon", "oeffnungszeiten", "bewertung"]
  },
  {
    name: "Apothekensuche",
    type: "pharmacies",
    endpoints: [
      "https://www.aponet.de/apotheke/notdienstsuche",
      "https://www.apotheken.de/"
    ],
    extractFields: ["name", "adresse", "telefon", "notdienst"]
  },
  {
    name: "Krankenkassen-Verzeichnis",
    type: "health_services",
    endpoints: [
      "https://www.kvsa.de/", // KV Sachsen-Anhalt
      "https://www.aok.de/pk/sachsen-anhalt/"
    ]
  }
];

// DeepSearch Funktion erweitern
async function deepSearchHealth(query, options = {}) {
  const results = {
    doctors: [],
    pharmacies: [],
    fitness: [],
    care_services: []
  };
  
  // Lokale Datenbank zuerst
  const localResults = searchLocalHealthData(query, options);
  
  // Externe Quellen (falls aktiviert)
  if (options.includeExternal) {
    const externalResults = await searchExternalHealthSources(query);
    // Merge und Deduplizieren
    mergeHealthResults(results, externalResults);
  }
  
  return results;
}
```

### Notdienst-API Integration

```javascript
// Apotheken-Notdienst abrufen
async function getPharmacyEmergencyService(plz, datum = new Date()) {
  // Option 1: Offizielle API (falls verfügbar)
  // Option 2: Scraping von aponet.de
  // Option 3: Lokale Datenbank mit regelmäßigem Update
  
  const formattedDate = datum.toISOString().split('T')[0];
  
  try {
    // Beispiel API-Aufruf
    const response = await fetch(
      `https://www.aponet.de/service/notdienstsuche?plz=${plz}&datum=${formattedDate}`
    );
    
    // Parse und return
    const data = await response.json();
    return {
      apotheke: data.name,
      adresse: data.adresse,
      telefon: data.telefon,
      zeiten: data.notdienst_zeiten,
      koordinaten: { lat: data.lat, lng: data.lng }
    };
  } catch (error) {
    console.error('Notdienst-Abfrage fehlgeschlagen:', error);
    return getFallbackEmergencyPharmacy(plz);
  }
}

// Ärztlicher Bereitschaftsdienst Info
function getAerztlicherBereitschaftsdienst() {
  return {
    telefon: "116 117",
    beschreibung: "Ärztlicher Bereitschaftsdienst - bundesweit, kostenlos",
    zeiten: "Außerhalb der Praxis-Öffnungszeiten",
    hinweis: "Bei lebensbedrohlichen Notfällen: 112"
  };
}
```

---

## Teil E: Daten-Sammlung

### Quellen für Gesundheitsdaten in MSH

```
Primäre Quellen:
□ KV Sachsen-Anhalt (kvsa.de) - Arztverzeichnis
□ Apothekerkammer Sachsen-Anhalt - Apothekenverzeichnis
□ Städtische Websites (Sangerhausen, Eisleben, Hettstedt)
□ Gelbe Seiten / Das Örtliche
□ Google Maps API (Öffnungszeiten, Bewertungen)

Sekundäre Quellen:
□ Jameda, Doctolib (Arzt-Bewertungen)
□ AOK Arztnavigator
□ Lokale Zeitungen (Veranstaltungen, Seniorensport)

Zu sammelnde Daten:
□ Alle Hausärzte im Landkreis
□ Fachärzte (Kardiologen, Orthopäden, etc.)
□ Alle Apotheken + Notdienst-Plan
□ Physiotherapie-Praxen
□ Pflegedienste
□ Krankenhäuser / Notaufnahmen
□ Seniorensport-Angebote
```

---

## Test-Kriterien

- [ ] Tab "Gesundheit" erscheint in Navigation
- [ ] Notfall-Bereich ist prominent und funktional
- [ ] Telefon-Links öffnen Wähl-App (tel:)
- [ ] 112 und 116117 Buttons funktionieren
- [ ] Notdienst-Apotheke wird korrekt angezeigt
- [ ] Ärzte-Suche zeigt relevante Ergebnisse
- [ ] Filter (Fachrichtung, Barrierefrei, etc.) funktionieren
- [ ] "Jetzt geöffnet" Filter funktioniert korrekt
- [ ] Öffnungszeiten werden korrekt angezeigt
- [ ] Karten-Integration funktioniert
- [ ] Mobile: Große Touch-Targets
- [ ] Mobile: Lesbare Schriftgröße
- [ ] DeepSearch findet Gesundheits-Einrichtungen

---

## Deliverables

Nach Abschluss:
1. Neuer "Gesundheit" Tab implementiert
2. Datenstruktur dokumentiert
3. Mindestens Basisdaten vorhanden (Ärzte, Apotheken)
4. Notdienst-Funktion getestet
5. DeepSearch Integration bestätigt
6. Screenshot der Ansicht
