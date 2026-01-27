# Prompt 1: Familie & Gastro Filter reparieren

## Problem-Beschreibung

Die Alters-Filter im Familie/Gastro-Bereich sind **klickbar aber ohne Funktion**:
- "0-3 Jahre"
- "3-6 Jahre"  
- "6-12 Jahre"
- "12+ Jahre"

### Aktuelles Verhalten
- Filter-Buttons sind sichtbar und klickbar
- **Nichts passiert** beim Klick
- Kartenansicht ändert sich nicht
- Keine Navigation zu gefilterter Ansicht

### Erwartetes Verhalten
- Klick auf Alters-Filter → Kartenansicht mit passenden Orten
- Nur Orte anzeigen die für diese Altersgruppe relevant sind
- Filter sollte visuell als "aktiv" markiert sein
- Funktioniert auf **Mobile UND Desktop**

---

## Aufgaben

### 1. Analyse (ZUERST!)

```
Finde heraus:
□ Wo ist die Filter-Komponente? (Datei + Zeile)
□ Welche Click-Handler existieren bereits?
□ Wie sind die Orte mit Altersgruppen verknüpft?
□ Gibt es ein bestehendes Filter-System das genutzt werden kann?
□ Wie funktionieren andere Filter die FUNKTIONIEREN?
```

### 2. Fehler identifizieren

Mögliche Ursachen prüfen:
- [ ] Event-Listener fehlt oder ist falsch gebunden
- [ ] Filter-Logik existiert nicht
- [ ] Daten haben keine Alters-Kategorisierung
- [ ] State-Management Problem (Filter-State wird nicht angewendet)
- [ ] Mobile-spezifisches Touch-Event Problem

### 3. Implementierung

**Falls Event-Listener fehlt:**
```javascript
// Pseudo-Code Beispiel
filterButtons.forEach(button => {
  button.addEventListener('click', (e) => {
    const ageGroup = e.target.dataset.ageGroup;
    applyAgeFilter(ageGroup);
    updateMapView();
    setActiveFilterState(button);
  });
});
```

**Falls Filter-Logik fehlt:**
```javascript
function applyAgeFilter(ageGroup) {
  const ageRanges = {
    '0-3': { min: 0, max: 3 },
    '3-6': { min: 3, max: 6 },
    '6-12': { min: 6, max: 12 },
    '12+': { min: 12, max: 99 }
  };
  
  const filtered = locations.filter(loc => 
    loc.suitableFor?.includes(ageGroup) || 
    loc.ageRange?.min <= ageRanges[ageGroup].max
  );
  
  updateMapMarkers(filtered);
}
```

### 4. Visuelles Feedback

- Aktiver Filter sollte hervorgehoben sein (andere Farbe/Border)
- Anzahl der gefilterten Ergebnisse anzeigen (optional)
- "Filter zurücksetzen" Option

### 5. Mobile-Kompatibilität

- Touch-Events testen
- Tap-Feedback (kurze Animation/Farbe)
- Filter-Bereich muss scrollbar sein falls nötig

---

## Test-Kriterien

Nach der Implementierung prüfen:

- [ ] Klick auf "0-3 Jahre" → Nur passende Orte auf Karte
- [ ] Klick auf "3-6 Jahre" → Nur passende Orte auf Karte
- [ ] Klick auf "6-12 Jahre" → Nur passende Orte auf Karte
- [ ] Klick auf "12+ Jahre" → Nur passende Orte auf Karte
- [ ] Aktiver Filter ist visuell markiert
- [ ] Erneuter Klick → Filter deaktivieren (oder Toggle)
- [ ] Funktioniert auf Mobile (Touch)
- [ ] Funktioniert auf Desktop (Click)
- [ ] Karte zoomt/pannt sinnvoll zu gefilterten Ergebnissen

---

## Hinweise

- Schau dir an wie **funktionierende Filter** (z.B. Event-Filter) implementiert sind
- Nutze das bestehende Pattern, erfinde nicht neu
- Console.log zum Debuggen: Wird der Click überhaupt registriert?
- Prüfe Browser DevTools → Event Listeners Tab

---

## Deliverables

Nach Abschluss:
1. Kurze Beschreibung was das Problem war
2. Welche Dateien wurden geändert
3. Bestätigung dass Tests bestanden
