# Oggauer Gemeindetrommler 🥁

Die **Oggauer Gemeindetrommler App** ist eine mobile Anwendung (Flutter für Android & iOS) für Bürgerinnen und Bürger der Marktgemeinde Oggau am Neusiedler See. Sie dient als digitale Plattform für Gemeinde-Nachrichten, Bürgeranliegen (Mängelmeldungen mit Foto-Upload) sowie den Austausch im Bürgerforum bzw. die Einbringung von Gemeinde-Ideen inklusive PDF-Exportfunktionen.

---

## 📱 Aktueller Funktionsumfang (Ist-Zustand)

Die App wurde in ihrer Erstversion mit Unterstützung von KI (frühe GPT-Modelle) entwickelt und nutzt Firebase als Backend.

### 1. Neuigkeiten (`News`)
- Liste aktueller Berichte und Neuigkeiten aus der Gemeinde mit Datum, Überschrift, Textvorschau und Beitragsbild.
- Detailansicht mit vollständigem Text und großem Beitragsbild.
- PDF-Export: Sowohl Einzelbeiträge als auch eine Mehrfachauswahl können direkt als PDF generiert und geteilt werden.

### 2. Mängelübersicht & Mängelmeldung (`Issues`)
- Übersicht über gemeldete Mängel im Ortsgebiet (chronologisch sortiert).
- Erfassung neuer Mängel mit Titel, Beschreibungstext und Foto (Kamera oder Galerie).
- Automatischer Zuschnitt (1:1 Quadrat) und Größenvalidierung (< 10 MB).
- Eigene Meldungen können per Wischgeste (Swipe-to-Delete) entfernt werden.
- Mehrfachauswahl von Mängeln mit Sammel-PDF-Export (z. B. zur Weiterleitung an den Bauhof).

### 3. BürgerForum / Ideen (`CitizensForum`)
- Plattform zur Einbringung von Anregungen und Vorschlägen für das Gemeindeleben.
- Nutzt aktuell den gleichen Erfassungs- und PDF-Export-Workflow wie bei den Mängeln.

### 4. Authentifizierung (`AuthState`)
- Anonyme Firebase-Authentifizierung (`FirebaseAuth.signInAnonymously`).
- Lesemodus für Gäste; Erstellen und Löschen eigener Beiträge ist an den angemeldeten Nutzerstatus gekoppelt.

---

## 🔍 Soll vs. Ist Abgleich (Original-Anforderungen)

Basierend auf dem ursprünglichen Lastenheft von Thomas und den UI-Wireframes (`App (1).xlsx`) ergibt sich folgender Umsetzungsstatus:

| Anforderung / Modul | Ursprüngliche Spezifikation | Aktueller Umsetzungsstatus | Status |
|---|---|---|---|
| **Startseite / News** | 2-Zeilen-Vorschau, Trennlinie, Volltextsuche (Lupe), Detailansicht, PDF/JPG-Anhänge | Überschrift, Datum, 3 Zeilen Text, Bild, Detailansicht | 🟡 Teilweise (Suche fehlt, nur 1 Bild) |
| **Mängelübersicht** | Liste, Volltextsuche, PDF-Tabellendruck einer Auswahl | Liste vorhanden, Checkbox-Auswahl + PDF-Druck integriert | 🟡 Teilweise (Suche & Tabellenlayout im PDF fehlen) |
| **Mängelerfassung** | Pflicht-Dropdown für Straße/Ort, Dropdown für Grundlage, max. 2 Fotos im Querformat (max. 800x600), automatischer Verfasser | Titel, Beschreibung, 1 Foto im Quadrat (1:1). Keine Dropdowns | 🔴 Wesentliche Felder fehlen |
| **Ideen** | Wie Mängel, bis zu 5 Anhänge (PDF/Bilder), kein Druck erforderlich | Als „BürgerForum“ realisiert, aber identische Maske zu Mängeln (nur 1 Bild) | 🟡 Teilweise (Mehrfach-Upload bis 5 Dateien fehlt) |
| **Kontakt** | Freitext, Name, Nachname, E-Mail (Pflicht), Rückrufnummer (optional), E-Mail-Versand, Rechtshinweis | Nicht im Menü eingebunden; nur Registrier-Fragmente vorhanden | 🔴 Fehlt komplett |
| **Information / Impressum** | Öffentliche Gemeinde-Infos, Veranstaltungen, Impressum ohne Login frei zugänglich | Nicht vorhanden | 🔴 Fehlt komplett |
| **Zugangsschutz / Auth** | Gemeindebürger-Zugang via Passwort/Freigabe; nur Info-Bereich offen | Anonymer Login per Knopfdruck für alle; Fragmente für E-Mail-Login | 🔴 Entspricht nicht dem Passwort-Konzept |
| **Design & Header** | Neutraler Hintergrund, optionales Betreiber-Logo im Header | Schlichter Material-AppBar-Header ohne Logo | 🟡 Optimierbar |

---

## 🏗️ Technische Architektur & Tech-Stack

### Verwendete Technologien:
- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `>=2.18.2 <3.0.0` / Dart 3 kompatibel)
- **Backend / Cloud Services (Firebase):**
  - `firebase_core` (Core-Initialisierung)
  - `firebase_auth` (Authentifizierung)
  - `cloud_firestore` (NoSQL Echtzeitdatenbank für News, Mängel, Ideen)
  - `firebase_storage` (Speicherung hochgeladener Bilder)
- **PDF-Erstellung & Druck:** `pdf`, `printing`
- **Bildverarbeitung:** `image`, `image_picker`, `image_cropper`, `cached_network_image`
- **State Management:** `provider`

### Projektstruktur (`lib/`):
```text
lib/
├── firebase_options.dart   # Firebase-Projektkonfiguration (Android & iOS)
├── main.dart               # App-Einstiegspunkt, Firebase Init & MultiProvider
├── models/
│   └── post_item.dart      # Typisiertes Datenmodell für News, Mängel & Ideen
├── screens/
│   ├── add_issue_screen.dart # Mängelerfassung mit Straßenauswahl & bis zu 2 Fotos
│   ├── add_post_screen.dart  # Universelle Erfassung für News & Bürgerideen
│   ├── auth_dialog.dart      # Anmelde-, Registrierungs- & Code-Freischaltungs-Dialog
│   ├── contact_screen.dart   # Bürgerforum-Kontaktformular & Anfragen
│   ├── detail_screen.dart    # Detailansicht mit Metadaten & PDF-Einzelexport
│   ├── home_screen.dart      # Haupt-Scaffold mit 5 Tabs (News, Mängel, Ideen, Kontakt, Info)
│   ├── info_screen.dart      # Bürgerforum Leitbild, Notrufnummern & Account-Status
│   └── post_list_screen.dart # Universelle Listenansicht, Echtzeitsuche & PDF-Tabelle
└── services/
    ├── auth_service.dart     # Hybrid-Auth (E-Mail/Passwort, Bürger-Code, Anonym)
    ├── firestore_service.dart# NoSQL CRUD & Kontaktanfragen
    ├── pdf_service.dart      # PDF-Druckerzeugung (Listen & Einzelansichten)
    └── storage_service.dart  # Optimierter Bild-Upload (Querformat max 800x600)
```

---

## 🤖 CI/CD Pipeline (Gitea Actions)

Die App verfügt über eine vollautomatische Build-Pipeline für **Gitea Actions** (`.gitea/workflows/build-apk.yaml`):

### Funktionen der Pipeline:
- **Automatische Trigger:** Wird bei jedem `push` auf `main`, `master`, `refactor/**`, bei Git-Tags (`v*`) oder manuell im Webinterface (`workflow_dispatch`) ausgelöst.
- **Isolierte Build-Umgebung:** Nutzt das offizielle `ghcr.io/cirruslabs/flutter:3.19.3` Docker-Image mit vorinstalliertem Android SDK, Java 17 und Flutter.
- **Qualitätssicherung:** Führt automatisch `flutter analyze` und `flutter test` aus, bevor der Build startet.
- **Vollständige APK-Generierung:**
  - `oggauer-gemeindetrommler-universal-release.apk` (Universelle Release-APK für alle Android-Geräte)
  - `oggauer-gemeindetrommler-arm64-v8a.apk` (Für moderne 64-Bit Smartphones)
  - `oggauer-gemeindetrommler-armeabi-v7a.apk` (Für ältere 32-Bit Smartphones)
  - `oggauer-gemeindetrommler-x86_64.apk` (Für Emulatoren & ChromeOS)
- **Artifact-Upload:** Speichert die fertigen APKs als herunterladbare ZIP-Datei (`oggauer-gemeindetrommler-apks`) direkt im Gitea Run-Dashboard.

### APKs in Gitea herunterladen:
1. Im Gitea-Repository auf den Reiter **Aktionen** (*Actions*) klicken.
2. Den gewünschten Pipeline-Durchlauf auswählen.
3. Im Abschnitt **Artefakte** (*Artifacts*) das Paket `oggauer-gemeindetrommler-apks` herunterladen.

---

## 🛠️ Einrichtung & Lokaler Start

### Voraussetzungen
1. **Flutter SDK** (empfohlen: `>= 3.19.x`)
2. **Dart SDK** (enthalten in Flutter)
3. **Android Studio** / **Xcode** (für Emulatoren oder physische Geräte)
4. Konfiguriertes Firebase-Projekt (`gemeinde-trommler`)

### Installation & Ausführung
```bash
# 1. Abhängigkeiten installieren
flutter pub get

# 2. Statische Code-Analyse ausführen
flutter analyze

# 3. Tests ausführen
flutter test

# 4. App lokal starten
flutter run
```

---

## 📄 Lizenz & Urheberschaft
Entwickelt für das **Bürgerforum Oggau**. Private & gemeinnützige Verwendung.
