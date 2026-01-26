# MSH Map Analytics - Vercel Deployment Guide

Vollständige Anleitung zum Deployment der MSH Map Analytics auf Vercel (kostenlose Alternative zu Firebase Cloud Functions).

## Warum Vercel?

- **Kostenlos**: Hobby Plan ohne Kreditkarte
- **Großzügige Limits**: 100GB Bandwidth, 100h Serverless Execution/Monat
- **Cron Jobs**: Automatische Scheduled Functions inklusive
- **Einfach**: Einfacheres Setup als Firebase Functions

## Voraussetzungen

1. **Vercel Account**: [vercel.com/signup](https://vercel.com/signup)
2. **Vercel CLI**:
   ```bash
   npm install -g vercel
   ```
3. **Firebase Service Account**: Siehe unten

## Schritt 1: Firebase Service Account erstellen

1. Öffne [Firebase Console](https://console.firebase.google.com)
2. Wähle dein Projekt: `lunch-radar-5d984`
3. Gehe zu **Project Settings** (Zahnrad-Symbol)
4. Tab **Service Accounts**
5. Klicke **Generate New Private Key**
6. Speichere die JSON-Datei sicher

Die JSON-Datei sieht so aus:
```json
{
  "type": "service_account",
  "project_id": "lunch-radar-5d984",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-...@lunch-radar-5d984.iam.gserviceaccount.com",
  ...
}
```

## Schritt 2: Dependencies installieren

```bash
cd api
npm install
```

Dies installiert:
- `@vercel/node` - Vercel Runtime
- `firebase-admin` - Firebase Admin SDK
- `typescript` - TypeScript Compiler
- `vercel` - Vercel CLI

## Schritt 3: Lokales Testing (optional)

### Environment Variables setzen

Erstelle `api/.env.local`:

```bash
# Firebase
FIREBASE_PROJECT_ID=lunch-radar-5d984
FIREBASE_SERVICE_ACCOUNT='{"type":"service_account",...}'  # Komplette JSON aus Schritt 1

# Cron Secret (optional)
CRON_SECRET=my-secret-key
```

**Wichtig**: Die `FIREBASE_SERVICE_ACCOUNT` muss ein **einzeiliger JSON-String** sein (keine Zeilenumbrüche).

### Lokalen Dev-Server starten

```bash
cd api
npm run dev
```

Dies startet Vercel Dev Server auf `http://localhost:3000`.

### Endpoints testen

```bash
# Manuelle Berechnung
curl http://localhost:3000/api/recalculate-all

# Daily Stats (simuliert Cron)
curl http://localhost:3000/api/scheduled/daily-stats

# Weekly Report
curl http://localhost:3000/api/scheduled/weekly-report
```

## Schritt 4: Vercel Projekt erstellen

### Via CLI (empfohlen)

```bash
# Im Projekt-Root (Lunch-Radar/)
vercel login
vercel
```

Folge den Prompts:
- **Set up and deploy?** → Yes
- **Which scope?** → Wähle deinen Account
- **Link to existing project?** → No
- **Project name?** → `msh-map-analytics` (oder eigener Name)
- **In which directory is your code located?** → `./` (Root)
- **Want to modify settings?** → No

### Via Web Dashboard (Alternative)

1. Öffne [vercel.com/new](https://vercel.com/new)
2. Importiere Git Repository (GitHub/GitLab)
3. **Framework Preset**: Other
4. **Root Directory**: `./` (leer lassen)
5. Klicke **Deploy**

## Schritt 5: Environment Variables in Vercel setzen

**Kritisch**: Ohne diese Variables funktionieren die Functions nicht!

### Via CLI

```bash
# FIREBASE_SERVICE_ACCOUNT setzen (aus Schritt 1)
vercel env add FIREBASE_SERVICE_ACCOUNT

# Paste den kompletten JSON als einzeiligen String:
# {"type":"service_account","project_id":"lunch-radar-5d984",...}

# Für welche Environments? Wähle: Production, Preview, Development

# FIREBASE_PROJECT_ID setzen
vercel env add FIREBASE_PROJECT_ID
# Wert: lunch-radar-5d984

# CRON_SECRET setzen (optional, aber empfohlen)
vercel env add CRON_SECRET
# Generiere Secret: openssl rand -base64 32
```

### Via Web Dashboard

1. Gehe zu [vercel.com/dashboard](https://vercel.com/dashboard)
2. Wähle dein Projekt
3. **Settings** → **Environment Variables**
4. Füge hinzu:
   - **Name**: `FIREBASE_SERVICE_ACCOUNT`
     - **Value**: `{"type":"service_account",...}` (komplette JSON)
     - **Environments**: Production, Preview, Development
   - **Name**: `FIREBASE_PROJECT_ID`
     - **Value**: `lunch-radar-5d984`
   - **Name**: `CRON_SECRET`
     - **Value**: (generierter Secret)

## Schritt 6: Deployment

### Automatisch (via Git)

Wenn du Vercel mit GitHub/GitLab verbunden hast:
```bash
git add .
git commit -m "Add Vercel analytics functions"
git push
```

Vercel deployed automatisch bei jedem Push.

### Manuell (via CLI)

```bash
# Production Deployment
vercel --prod

# Preview Deployment
vercel
```

Nach erfolgreichem Deployment erhältst du URLs:
```
✅ Production: https://msh-map-analytics.vercel.app
✅ Preview: https://msh-map-analytics-git-main-username.vercel.app
```

## Schritt 7: Cron Jobs aktivieren

**Wichtig**: Vercel Cron Jobs funktionieren nur im **Production** Deployment!

Die Cron Jobs sind in [vercel.json](vercel.json) definiert:
- **Daily Stats**: Täglich 3 Uhr (UTC) → `/api/scheduled/daily-stats`
- **Weekly Report**: Sonntags 6 Uhr (UTC) → `/api/scheduled/weekly-report`

### Cron Jobs verifizieren

1. Gehe zu [vercel.com/dashboard](https://vercel.com/dashboard)
2. Wähle dein Projekt
3. **Deployments** → Production Deployment
4. **Functions** → Sollte zeigen:
   - `api/scheduled/daily-stats.ts`
   - `api/scheduled/weekly-report.ts`
   - `api/recalculate-all.ts`

### Manuelle Trigger (für Testing)

```bash
# Production URL
curl https://msh-map-analytics.vercel.app/api/recalculate-all

# Mit CRON_SECRET (wenn gesetzt)
curl -H "Authorization: Bearer YOUR_CRON_SECRET" \
  https://msh-map-analytics.vercel.app/api/scheduled/daily-stats
```

## Schritt 8: Logs überwachen

### Via CLI

```bash
vercel logs --follow
```

### Via Web Dashboard

1. [vercel.com/dashboard](https://vercel.com/dashboard)
2. Projekt auswählen
3. **Deployments** → Deployment auswählen
4. **Functions** → Function auswählen → **View Logs**

## Projekt-Struktur

```
Lunch-Radar/
├── api/                          # Vercel Serverless Functions
│   ├── analytics/
│   │   ├── aggregation.ts        # Region/Stadt Stats
│   │   ├── gaps.ts               # Gap Detection
│   │   └── insights.ts           # Insight Generation
│   ├── utils/
│   │   ├── firebase.ts           # Firebase Admin Init
│   │   └── geo.ts                # Geo-Berechnungen
│   ├── scheduled/
│   │   ├── daily-stats.ts        # Cron: Täglich 3 Uhr
│   │   └── weekly-report.ts      # Cron: Sonntags 6 Uhr
│   ├── recalculate-all.ts        # HTTP Endpoint
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
│
├── vercel.json                   # Vercel Config + Cron Jobs
└── VERCEL_DEPLOYMENT.md          # Diese Datei
```

## API Endpoints

Nach dem Deployment sind folgende Endpoints verfügbar:

### 1. Manuelle Neuberechnung (HTTP)

```bash
GET/POST https://YOUR-PROJECT.vercel.app/api/recalculate-all
```

**Response:**
```json
{
  "success": true,
  "message": "All analytics recalculated successfully",
  "timestamp": "2026-01-26T..."
}
```

**Verwendung**: Manuelle Trigger oder nach Daten-Import

### 2. Daily Stats (Cron)

```bash
GET https://YOUR-PROJECT.vercel.app/api/scheduled/daily-stats
Authorization: Bearer YOUR_CRON_SECRET
```

**Schedule**: Täglich 3 Uhr (UTC)

**Was passiert**:
- Region Overview aktualisieren
- Stadt-Statistiken berechnen
- Gaps erkennen
- Insights generieren

### 3. Weekly Report (Cron)

```bash
GET https://YOUR-PROJECT.vercel.app/api/scheduled/weekly-report
Authorization: Bearer YOUR_CRON_SECRET
```

**Schedule**: Sonntags 6 Uhr (UTC)

**Was passiert**:
- Wöchentlichen Summary-Report generieren
- In Firestore `reports` Collection speichern

## Firestore Collections

Die Vercel Functions schreiben in dieselben Firestore Collections wie Firebase Functions:

```
firestore/
├── locations/              # Orte (manuell importiert)
├── analytics/
│   ├── region_overview     # Gesamt-Übersicht
│   ├── city_stats/cities/  # Stadt-Statistiken
│   ├── gaps/items/         # Infrastruktur-Lücken
│   └── insights/items/     # Automatische Insights
└── reports/                # Wöchentliche Reports
```

## Workflow: Seed-Daten → Vercel → Firestore

### 1. Seed-Daten exportieren

```bash
cd deepscan
python deepscan_main.py --seed
```

**Output**: `deepscan/output/merged/msh_firestore_[TIMESTAMP].json`

### 2. In Firestore importieren

```python
import json
import firebase_admin
from firebase_admin import firestore

firebase_admin.initialize_app()
db = firestore.client()

# Lade Export
with open('deepscan/output/merged/msh_firestore_20260126_XXXXXX.json') as f:
    data = json.load(f)

# Batch-Import
batch = db.batch()
for loc_id, loc_data in data['locations'].items():
    batch.set(db.collection('locations').document(loc_id), loc_data)
batch.commit()
```

### 3. Analytics triggern

```bash
curl https://YOUR-PROJECT.vercel.app/api/recalculate-all
```

### 4. Ergebnisse prüfen

Firestore Console → `analytics` Collections ansehen

## Kosten & Limits (Hobby Plan)

Vercel Hobby Plan ist **komplett kostenlos**:

| Feature | Limit | MSH Map Nutzung |
|---------|-------|-----------------|
| **Bandwidth** | 100 GB/Monat | ~1-5 GB/Monat |
| **Serverless Execution** | 100 Stunden/Monat | ~2-3 Stunden/Monat |
| **Cron Jobs** | Unbegrenzt | 2 Jobs (täglich + wöchentlich) |
| **Invocations** | 1 Million/Monat | ~100/Monat |
| **Function Duration** | 10s (Hobby), 60s (konfiguriert) | ~5-10s pro Run |

**Ergebnis**: MSH Map bleibt weit unter den Limits → **100% kostenlos**

## Troubleshooting

### Error: "FIREBASE_SERVICE_ACCOUNT is required"

- Environment Variable in Vercel Dashboard nicht gesetzt
- Lösung: Siehe Schritt 5

### Error: "Invalid service account JSON"

- JSON ist nicht einzeilig oder hat Syntax-Fehler
- Lösung: JSON minifizieren (keine Zeilenumbrüche)
  ```bash
  cat service-account.json | jq -c . | pbcopy
  ```

### Cron Jobs laufen nicht

- Cron Jobs funktionieren nur in **Production** (nicht Preview)
- Lösung: `vercel --prod` deployen

### Functions timeout

- Default: 10s (Hobby), konfiguriert auf 60s
- Bei großen Datenmengen (>1000 Locations) kann das knapp werden
- Lösung: Batch-Größe in Functions reduzieren oder Pro Plan

### Firebase Permission Denied

- Service Account hat keine Firestore-Rechte
- Lösung:
  1. Firebase Console → IAM & Admin
  2. Service Account finden
  3. Rolle "Cloud Datastore User" hinzufügen

## Vergleich: Vercel vs Firebase Functions

| Feature | Vercel | Firebase Functions |
|---------|--------|-------------------|
| **Preis** | Kostenlos (Hobby) | Blaze Plan erforderlich |
| **Setup** | Einfacher | Komplexer |
| **Cron Jobs** | In vercel.json | Pub/Sub Schedule |
| **Firestore Triggers** | Nicht unterstützt | Unterstützt |
| **Cold Start** | ~500ms | ~1-2s |
| **Execution Time** | 60s (konfiguriert) | 60s (Standard) |
| **TypeScript** | Native | Via Build |

## Nächste Schritte

1. **Vercel deployen** (siehe Schritte 1-7)
2. **Seed-Daten importieren** (siehe Workflow)
3. **Analytics triggern**: `curl .../api/recalculate-all`
4. **Flutter Integration**: Dashboard mit Vercel API verbinden

## Support & Logs

- **Vercel Logs**: `vercel logs --follow`
- **Vercel Dashboard**: [vercel.com/dashboard](https://vercel.com/dashboard)
- **Firebase Console**: [console.firebase.google.com](https://console.firebase.google.com)
- **Vercel Docs**: [vercel.com/docs](https://vercel.com/docs)

## Sicherheit

- **CRON_SECRET**: Schützt Cron Endpoints vor unbefugten Aufrufen
- **CORS**: API ist öffentlich zugänglich (für Flutter App)
- **Service Account**: Nur Read/Write auf Firestore, keine Admin-Rechte

**Best Practice**: CRON_SECRET immer setzen!
