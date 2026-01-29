# Prompt 1: Fehlende Gesundheitsdaten ergänzen

## 🔴 KRITISCH - Lebensrettende Informationen müssen vollständig sein!

---

## Problem

Es fehlen Ärzte und Apotheken in der Datenbank, obwohl sie real existieren.

**Bekannte fehlende Einträge:**

| Typ | Name | Adresse | Telefon |
|-----|------|---------|---------|
| Arzt | Michael Zastava | Hallesche Str. 69, 06536 Südharz (bei EDEKA Lehne) | 034651 459805 |
| Apotheke | Kyffhäuser Apotheke | Hallesche Str. 59, 06536 Südharz | 034651 2431 |

---

## Aufgabe

### Schritt 1: Vollständige Datenextraktion aus OSM

Führe eine erweiterte Overpass API Abfrage durch:

```
// Overpass Turbo Query - Kopiere in https://overpass-turbo.eu/

[out:json][timeout:120];

// Bounding Box für Mansfeld-Südharz (erweitert)
(
  // Ärzte
  node["amenity"="doctors"](51.30,10.90,51.70,11.90);
  way["amenity"="doctors"](51.30,10.90,51.70,11.90);
  node["healthcare"="doctor"](51.30,10.90,51.70,11.90);
  
  // Apotheken
  node["amenity"="pharmacy"](51.30,10.90,51.70,11.90);
  way["amenity"="pharmacy"](51.30,10.90,51.70,11.90);
  
  // Krankenhäuser
  node["amenity"="hospital"](51.30,10.90,51.70,11.90);
  way["amenity"="hospital"](51.30,10.90,51.70,11.90);
  
  // Zahnärzte
  node["amenity"="dentist"](51.30,10.90,51.70,11.90);
  
  // AEDs
  node["emergency"="defibrillator"](51.30,10.90,51.70,11.90);
);

out body center;
```

### Schritt 2: Google Maps Recherche für bekannte fehlende Einträge

**Für Michael Zastava:**
```
Suchbegriff: "Michael Zastava Arzt Südharz"
Oder: "Arzt Hallesche Str 69 Südharz"
Oder: "EDEKA Lehne Südharz Arzt"

Erwartete Koordinaten: ca. 51.46xx, 11.0xxx (Roßla/Südharz Bereich)
```

**Für Kyffhäuser Apotheke:**
```
Suchbegriff: "Kyffhäuser Apotheke Südharz"
Oder: "Apotheke Hallesche Str 59 Südharz"

Erwartete Koordinaten: ca. 51.46xx, 11.0xxx
```

### Schritt 3: Koordinaten ermitteln

**Methode 1: Google Maps**
1. Adresse eingeben
2. Rechtsklick auf Gebäude
3. "Was ist hier?" oder Koordinaten kopieren

**Methode 2: Nominatim (OpenStreetMap)**
```
https://nominatim.openstreetmap.org/search?q=Hallesche+Str+69,+Südharz&format=json
```

**Methode 3: Manuell auf Karte**
1. Google Maps: "EDEKA Lehne Südharz" suchen
2. Nach Arztpraxis im/beim Gebäude suchen
3. Koordinaten notieren

### Schritt 4: In doctors.json einfügen

```json
// Neuer Eintrag für doctors.json
{
  "id": "arzt_sh_zastava",
  "type": "doctor",
  "name": "Michael Zastava",
  "latitude": 51.XXXXX,      // ← ERMITTELN!
  "longitude": 11.XXXXX,     // ← ERMITTELN!
  "street": "Hallesche Str. 69",
  "postalCode": "06536",
  "city": "Südharz",
  "locationNote": "Im EDEKA Lehne Gebäude",
  "phone": "+49 34651 459805",
  "specialization": "allgemein",  // ← PRÜFEN!
  "openingHours": null,           // ← RECHERCHIEREN!
  "isBarrierFree": null,
  "hasHouseCalls": null,
  "acceptsPublicInsurance": true,
  "acceptsPrivateInsurance": true,
  "languages": ["Deutsch"],
  "verified": false,
  "source": "customer_feedback",
  "addedDate": "2026-01-29"
}
```

### Schritt 5: In pharmacies.json einfügen

```json
// Neuer Eintrag für pharmacies.json
{
  "id": "apo_sh_kyffhaeuser",
  "type": "pharmacy",
  "name": "Kyffhäuser Apotheke",
  "latitude": 51.XXXXX,      // ← ERMITTELN!
  "longitude": 11.XXXXX,     // ← ERMITTELN!
  "street": "Hallesche Str. 59",
  "postalCode": "06536",
  "city": "Südharz",
  "phone": "+49 34651 2431",
  "openingHours": null,      // ← RECHERCHIEREN!
  "hasEmergencyService": null,
  "emergencyServiceInfo": null,
  "isBarrierFree": null,
  "hasDelivery": null,
  "verified": false,
  "source": "customer_feedback",
  "addedDate": "2026-01-29"
}
```

---

## Systematische Suche nach weiteren fehlenden Einträgen

### Methode: Vergleich OSM vs. arzt-auskunft.de

```javascript
// Pseudo-Code für Datenabgleich

const osmDoctors = await fetchOSMDoctors(MSH_BOUNDS);
const arztAuskunftDoctors = await scrapeArztAuskunft("Mansfeld-Südharz");

// Finde Einträge die in arzt-auskunft.de aber nicht in OSM sind
const missing = arztAuskunftDoctors.filter(aa => {
  return !osmDoctors.some(osm => 
    levenshteinDistance(osm.name, aa.name) < 3 ||
    (osm.street === aa.street && osm.city === aa.city)
  );
});

console.log("Fehlende Ärzte:", missing);
```

### Manuelle Prüfung pro Ort

Prüfe für jeden größeren Ort in MSH ob alle Ärzte erfasst sind:

| Ort | Ärzte in DB | Prüfung |
|-----|-------------|---------|
| Sangerhausen | ? | □ Google Maps Check |
| Eisleben | ? | □ Google Maps Check |
| Hettstedt | ? | □ Google Maps Check |
| Südharz/Roßla | ? | □ Google Maps Check |
| Mansfeld | ? | □ Google Maps Check |
| Gerbstedt | ? | □ Google Maps Check |
| Allstedt | ? | □ Google Maps Check |

**Google Maps Suchbegriffe:**
- "Arzt [Ortsname]"
- "Hausarzt [Ortsname]"
- "Apotheke [Ortsname]"
- "Zahnarzt [Ortsname]"

---

## Krankenhäuser-Daten ergänzen

### Bekannte Krankenhäuser in MSH

| Name | Ort | Status |
|------|-----|--------|
| HELIOS Klinik Sangerhausen | Sangerhausen | □ In DB? |
| HELIOS Klinik Lutherstadt Eisleben | Eisleben | □ In DB? |
| Klinik Hettstedt | Hettstedt | □ In DB? |

### hospitals.json Format

```json
{
  "id": "hospital_sg_helios",
  "type": "hospital",
  "name": "HELIOS Klinik Sangerhausen",
  "latitude": 51.XXXXX,
  "longitude": 11.XXXXX,
  "street": "[Adresse]",
  "postalCode": "06526",
  "city": "Sangerhausen",
  "phone": "[Telefon]",
  "emergencyPhone": "[Notaufnahme]",
  "website": "https://www.helios-gesundheit.de/...",
  "departments": [
    "Innere Medizin",
    "Chirurgie",
    "Gynäkologie",
    "..."
  ],
  "hasEmergencyRoom": true,
  "isBarrierFree": true,
  "verified": false
}
```

---

## AED-Daten mit Ortsangaben erweitern

### Aktuelles Problem
AEDs werden ohne Ortsangabe in der Übersicht angezeigt.

### Lösung: `locationDescription` Feld hinzufügen

```json
// aeds.json - Jeder Eintrag braucht locationDescription
{
  "id": "aed_001",
  "type": "aed",
  "latitude": 51.4725,
  "longitude": 11.2980,
  "street": "Markt 1",
  "city": "Sangerhausen",
  "locationDescription": "Rathaus Sangerhausen, Eingangsbereich",  // ← NEU!
  "accessibility": "24/7",
  "indoor": true,
  "floor": "EG",
  "verified": true
}
```

### Alle AEDs durchgehen und beschreiben

```
Für jeden AED:
1. Koordinaten auf Google Maps prüfen
2. Gebäude identifizieren
3. locationDescription schreiben:
   - "[Gebäudename], [genauer Standort]"
   - Beispiel: "Sparkasse Sangerhausen, Foyer links"
   - Beispiel: "REWE Markt Eisleben, beim Kundenservice"
```

---

## Checkliste

```
FEHLENDE ÄRZTE:
[ ] Michael Zastava Koordinaten ermittelt
[ ] Michael Zastava in doctors.json eingefügt
[ ] Weitere fehlende Ärzte per OSM-Abfrage gesucht
[ ] Weitere fehlende Ärzte per arzt-auskunft.de gesucht
[ ] Alle größeren Orte auf Google Maps geprüft

FEHLENDE APOTHEKEN:
[ ] Kyffhäuser Apotheke Koordinaten ermittelt
[ ] Kyffhäuser Apotheke in pharmacies.json eingefügt
[ ] Weitere fehlende Apotheken gesucht

KRANKENHÄUSER:
[ ] hospitals.json auf Vollständigkeit geprüft
[ ] HELIOS Sangerhausen vorhanden?
[ ] HELIOS Eisleben vorhanden?
[ ] Alle Krankenhäuser haben korrekte Koordinaten

AEDs:
[ ] Alle AEDs haben locationDescription
[ ] Beschreibungen sind verständlich
[ ] Standorte sind verifiziert
```

---

## Deliverables

1. **Aktualisierte doctors.json** mit neuen Einträgen
2. **Aktualisierte pharmacies.json** mit neuen Einträgen
3. **Aktualisierte aeds.json** mit locationDescription
4. **Prüfbericht:** Liste aller hinzugefügten Einträge mit Koordinaten
