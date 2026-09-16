# Oggauer Gemeindetrommler 🥁

Die **Oggauer Gemeindetrommler App** ist die offizielle Smartphone-Anwendung (Flutter für Android & iOS) des **Bürgerforums Oggau** für alle Bürgerinnen und Bürger der Marktgemeinde Oggau am Neusiedler See. 

Die App vereint aktuelle Gemeinde-Nachrichten, offizielle PDF-Aussendungen des Bürgerforums, einen bürgernahen Mängelmelder mit Foto-Upload, eine Ideenplattform sowie einen direkten Kontaktkanal mit integriertem Admin-Posteingang und vollständiger In-App-Benutzerverwaltung.

---

## 📱 Funktionsumfang & Module

### 1. 📰 Nachrichten & Offizielle PDF-Aussendungen (`News`)
- **Chronologischer Feed:** Vereint manuell erstellte Gemeinde-Nachrichten und die offiziellen Rundschreiben/Aussendungen des Bürgerforums nach Datum sortiert (neueste zuerst).
- **WordPress REST-API Anbindung:** Vollautomatische Synchronisation der Aussendungen von [buergerforumoggau.at](https://buergerforumoggau.at/category/aktuelles/aussendungen/) inklusive HTML-Bereinigung und PDF-Extraktion.
- **Offline-First:** Geladene Aussendungen werden lokal via `SharedPreferences` zwischengespeichert und stehen sofort beim App-Start sowie offline zur Verfügung.
- **Integrierter PDF-Reader:**
  - Flüssige In-App-Vorschau ohne externe App zwingend öffnen zu müssen.
  - **Stufenloser Zoom:** Gesten-Zoom (Pinch-to-Zoom von 0.8x bis 5.0x) und schwebendes Bedienfeld (`+`, `-`, `1:1` Reset auf 100%).
  - **Drucken & Teilen:** Direktes Teilen von PDFs via `Printing.sharePdf` und System-Druckfunktion.
  - **Browser-Aufruf:** Öffnen des Original-Dokuments im Standard-Webbrowser oder externen PDF-Viewer.
- **Filter-Leiste:** Schnelles Filtern nach `Alle`, `Aussendungen (PDF)` und `Aktuelles`.
- **Echtzeitsuche & PDF-Export:** Volltextsuche in Beiträgen sowie Export von Einzelbeiträgen oder Tabellenübersichten als PDF.
- **Redaktions-Funktion:** Berechtigte Administratoren können neue Nachrichten direkt über die App mit Titel, Text und Beitragsbild erfassen.

### 2. ⚠️ Mängelmelder (`Issues`)
- **Mängelübersicht:** Chronologische Liste aller im Gemeindegebiet gemeldeten Mängel mit Bildvorschau, Status und Ortsangabe.
- **Strukturierte Erfassung:**
  - Titel und detaillierte Beschreibung.
  - Kategorie-Auswahl (z. B. Straßenbeleuchtung, Straßenschäden, Grünflächen, Müll, Spielplätze).
  - Pflicht-Dropdown aller offiziellen Straßen in Oggau.
  - Bis zu 2 Fotos (Aufnahme direkt per Kamera oder Auswahl aus der Galerie).
  - Automatische Bildkomprimierung und Speicheroptimierung (< 10 MB).
- **Status-Workflow:** Verwaltung durch Administratoren (`Gemeldet` $\rightarrow$ `In Bearbeitung` $\rightarrow$ `Behoben`).
- **Sammel-PDF-Druck:** Mehrfachauswahl gemeldeter Mängel mit tabellarischem PDF-Export (ideal zur Weiterleitung an den Bauhof oder Gemeinderat).
- **Löschfunktion:** Verfasser und Administratoren können Meldungen per Wischgeste entfernen.

### 3. 💡 BürgerForum & Ideen (`CitizensForum`)
- Bürger-Beteiligungsplattform für Anregungen, Projektideen und Initiativen zur Dorfentwicklung.
- Erfassung mit Titel, Freitextbeschreibung und bis zu 2 Fotos/Anhängen.
- PDF-Export und Druckunterstützung zur Vorstellung in Ausschüssen oder Sitzungen.

### 4. 📬 Kontakt & Admin-Posteingang (`Contact`)
- **Bürger-Kontaktformular:**
  - Einfache und direkte Kontaktaufnahme mit dem Bürgerforum.
  - Pflichtangaben: Name, E-Mail-Adresse und Anliegen.
  - Optionale Rückruf-Telefonnummer für schnelle Rückfragen.
  - Rechtlicher Datenschutzhinweis.
- **Admin-Posteingang (`AdminMessagesScreen`):**
  - Administratoren haben direkten Zugriff auf alle über die App eingesendeten Bürgernachrichten.
  - **Echtzeit-Aktualisierung** via Firestore.
  - **Filter-Chips:** Schnelles Filtern nach `Alle`, `Neu`, `In Bearbeitung` und `Erledigt`.
  - **Volltextsuche:** Durchsucht Betreff, Nachrichtentext, Absender-Name und E-Mail-Adresse.
  - **Detail-Ansicht (Bottom Sheet):**
    - Vollständiger Nachrichtentext mit Metadaten und Zeitstempel.
    - Statuswechsel (`Neu`, `In Bearbeitung`, `Erledigt`).
    - Ein-Klick-Aktionen: Direkte E-Mail-Antwort (`mailto:`) und Anruf (`tel:`).
    - Sicheres Löschen erledigter Nachrichten.

### 5. ℹ️ Bürgerforum-Info, Leitbild & In-App-Benutzerverwaltung (`Info`)
- **Leitbild & Über uns:** Informationen über die Grundsätze, Ziele und Aktivitäten des Bürgerforums Oggau.
- **Notrufnummern:** Wichtige Notfallkontakte (Feuerwehr, Polizei, Rettung, Euronotruf, Vergiftungszentrale, etc.) auf einen Blick mit direkter Anruffunktion.
- **Benutzerkonto-Status:** Transparente Anzeige des Anmeldestatus (`Gast`, `Bürger`, `Administrator`).
- **In-App-Benutzerverwaltung (`UserManagementScreen`):**
  - Keine Notwendigkeit mehr, für die Rollenvergabe die Firebase Console zu öffnen.
  - Vollständige Liste aller registrierten Bürger mit Such- und Filterfunktion (`Alle`, `Administratoren`, `Bürger`).
  - **Admin-Rechte verwalten:** Beförderung zum Administrator oder Entzug von Admin-Rechten mit einem Klick (inklusive Sicherheits-Bestätigungsdialog).
  - **Selbstentzugs-Schutz:** Der angemeldete Admin kann sich nicht versehentlich selbst die Administrationsrechte entziehen.
  - **Manuelle Admin-Freischaltung:** Zusätzliche Dialog-Eingabe zur direkten Autorisierung per E-Mail oder UID.

---

## 🔒 Sicherheitsarchitektur (Backend & Frontend)

Die Sicherheit und Integrität der Bürgerdaten wird durch ein mehrstufiges Sicherheitskonzept gewährleistet:

1. **Firestore Security Rules (`firestore.rules`):**
   - **`/Users/{userId}`:** Nutzer können ihr eigenes Profil lesen und pflegen. Nur Administratoren (`isAdmin()`) haben Vollzugriff auf alle Benutzerprofile.
   - **`/Admins/{adminDoc}`:** Schreib- und Löschrechte sind strikt auf bestehende Administratoren beschränkt.
   - **`/ContactMessages/{doc}`:** Eingereichte Kontaktanfragen können ausschließlich von Administratoren oder dem jeweiligen Verfasser gelesen werden. Statusänderungen und Löschungen sind Administratoren vorbehalten.
   - **`/News/{newsId}`:** Erstellen und Löschen von News-Beiträgen ist nur für Administratoren gestattet.
   - **`/Issues` & `/CitizensForum`:** Angemeldete Nutzer dürfen eigene Beiträge erfassen und löschen; Admins dürfen den Bearbeitungsstatus pflegen.
2. **Cloud Storage Rules (`storage.rules`):**
   - Uploads sind auf angemeldete Nutzer, Dateigrößen unter 10 MB und gültige Bildformate (`image/*`) limitiert.
   - Fotos dürfen ausschließlich vom ursprünglichen Verfasser oder von einem berechtigten Administrator gelöscht werden.
3. **Automatische Profil-Synchronisation:**
   - Bei jeder Anmeldung oder Registrierung gleicht `AuthService` das Benutzerprofil mit Firestore (`Users/{uid}`) ab.

---

## 📊 Umsetzungsstatus (Soll vs. Ist)

| Anforderung / Modul | Spezifikation & Features | Umsetzungsstatus | Status |
|---|---|---|:---:|
| **News & Aussendungen** | Chronologischer Feed, Volltextsuche, PDF-Aussendungen der Webseite, Zoom-Viewer, PDF-Export | Vollständig integriert (WordPress REST-API, In-App Zoom Reader, Filter-Chips) | 🟢 Erledigt |
| **Mängelübersicht** | Chronologische Liste, Straßenauswahl, Volltextsuche, Tabellen-PDF-Export, Status-Tracking | Vollständig integriert (Dropdown aller Oggauer Straßen, Statusanzeige, PDF-Export) | 🟢 Erledigt |
| **Mängelerfassung** | Pflicht-Straße, Kategorie, max. 2 Fotos, automatische Komprimierung, Verfasser-Zuordnung | Vollständig integriert (Kamera/Galerie, Dual-Foto-Upload, Validierung) | 🟢 Erledigt |
| **Bürgerforum / Ideen** | Bürgerbeteiligung, Beschreibung, bis zu 2 Anhänge, PDF-Export | Vollständig integriert | 🟢 Erledigt |
| **Kontakt & Posteingang** | Kontaktformular mit Validierung, Datenschutzhinweis, Admin-Nachrichten-Posteingang | Vollständig integriert (Echtzeit-Inbox, Status-Workflow, Schnellantwort) | 🟢 Erledigt |
| **Benutzerverwaltung** | Rollenverwaltung (Admin/Bürger), Kontoverwaltung in der App ohne Firebase Console | Vollständig integriert (In-App User Management, Selbstschutz, Echtzeit) | 🟢 Erledigt |
| **Info & Notruf** | Leitbild Bürgerforum, Gemeinde-Informationen, Notfallnummern mit Schnellwahl | Vollständig integriert | 🟢 Erledigt |
| **Authentifizierung & Rechte** | E-Mail/Passwort, Bürger-Freischaltung, Rollenkonzept, Gast-Zugang, Security Rules | Vollständig integriert & backend-seitig gehärtet | 🟢 Erledigt |

---

## 🏗️ Technische Architektur & Tech-Stack

### Verwendete Technologien:
- **Framework:** [Flutter](https://flutter.dev) `3.47.x` (Dart SDK `>=3.11`), Android `minSdk 23`, iOS `>= 15.0`
- **Backend & Cloud Services (Google Firebase):**
  - `firebase_core` (Initialisierung)
  - `firebase_auth` (E-Mail & Passwort Authentifizierung, Gast-Modus)
  - `cloud_firestore` (NoSQL Echtzeit-Datenbank)
  - `firebase_storage` (Cloud-Bilderspeicher)
- **Externe APIs & Web-Services:**
  - WordPress REST-API (`http`-Paket für Bürgerforum-Aussendungen)
  - `shared_preferences` (Offline-Zwischenspeicherung)
- **Dokumentenverarbeitung & PDF:**
  - `pdf`, `printing` (PDF-Generierung, In-App Vorschau & Druck)
  - `url_launcher` (System-Browser, Telefon- und E-Mail-Intents)
- **Bildverarbeitung:**
  - `image_picker`, `cached_network_image`, `image`
- **State Management:**
  - `provider` (`MultiProvider` Architektur)

### Projektstruktur (`lib/`):
```text
lib/
├── firebase_options.dart          # Firebase-Konfiguration für Android & iOS
├── main.dart                      # Einstiegspunkt, Theme & MultiProvider Setup
├── models/
│   └── post_item.dart             # Datenmodell für News, Aussendungen, Mängel & Ideen
├── screens/
│   ├── add_issue_screen.dart      # Mängelerfassung (Straßen-Dropdown & bis zu 2 Fotos)
│   ├── add_post_screen.dart       # Erfassung von News (Admins) & Bürgerideen
│   ├── admin_messages_screen.dart # Admin-Posteingang für eingegangene Kontaktanfragen
│   ├── auth_dialog.dart           # Anmelde-, Registrierungs- & Freischaltungs-Dialog
│   ├── contact_screen.dart        # Bürger-Kontaktformular mit Admin-Posteingang-Banner
│   ├── detail_screen.dart         # Beitrags-Detailansicht mit PDF-Direktaufruf
│   ├── home_screen.dart           # Haupt-Navigation mit 5 Tabs
│   ├── info_screen.dart           # Bürgerforum Leitbild, Notrufnummern & Kontostatus
│   ├── pdf_viewer_screen.dart     # In-App PDF-Viewer mit Pinch-to-Zoom & Schwebepanel
│   ├── post_list_screen.dart      # News-, Mängel- & Ideen-Listen mit Volltextsuche & Filter
│   └── user_management_screen.dart# In-App Benutzerverwaltung & Admin-Rollenvergabe
└── services/
    ├── aussendungen_service.dart  # WordPress REST-API Client mit SharedPreferences-Cache
    ├── auth_service.dart          # Authentifizierung & automatischer Firestore-Profilabgleich
    ├── firestore_service.dart     # Firestore CRUD, Admin-Verwaltung & Kontakt-Stream
    ├── pdf_service.dart           # PDF-Tabellen und Einzeldokument-Erstellung
    └── storage_service.dart       # Komprimierter Cloud-Storage Bild-Upload
```

---

## 🤖 CI/CD Pipeline

Die Flutter-Version ist zentral gepinnt (`FLUTTER_VERSION` in beiden Workflows, `environment` in `pubspec.yaml`) und muss bei einem Upgrade an allen drei Stellen gemeinsam angehoben werden.

### Android (Gitea Actions, `.gitea/workflows/build-apk.yaml`)

- **Build-Container:** `ghcr.io/cirruslabs/flutter:3.44.0` (letztes von Cirrus Labs veröffentlichtes Image, liefert JDK 21 + Android SDK 36). Das darin enthaltene Flutter-SDK wird im ersten Schritt per `git checkout` auf `FLUTTER_VERSION` umgeschaltet.
- **Runner:** Oracle Cloud ARM64 – x86_64-Werkzeuge (AAPT2, `gen_snapshot`) laufen über QEMU (`scripts/ci/qemu_intercept.c`).
- **Automatisierte Qualitätskontrolle:** Führt vor jedem Build `flutter analyze` und `flutter test` aus.
- **Erzeugte APK-Pakete:**
  1. `oggauer-gemeindetrommler-universal-release.apk` (Universelle Version für alle Android-Smartphones).
  2. `oggauer-gemeindetrommler-arm64-v8a.apk` (Optimiert für moderne 64-Bit Geräte).
  3. `oggauer-gemeindetrommler-armeabi-v7a.apk` (Für ältere 32-Bit Geräte).
  4. `oggauer-gemeindetrommler-x86_64.apk` (Für Emulatoren).
- **Download:** Die gebauten APKs stehen nach jedem Durchlauf als Artefakte im Gitea-Reiter **Aktionen** sowie im Release `latest` zum Download bereit.

### iOS (GitHub Actions, `.github/workflows/build-ios.yaml`)

- **Runner:** `macos-26` (Xcode 26), Flutter über `subosito/flutter-action`.
- **Plugins:** ausschließlich über CocoaPods (Swift Package Manager ist im Workflow bewusst deaktiviert); `ios/Podfile.lock` wird nicht versioniert, `pod install` läuft bei jedem Build frisch.
- **Ergebnis:** unsigniertes IPA (`flutter build ios --release --no-codesign`) als Artefakt `oggauer-gemeindetrommler-ios` – für die Verteilung muss es nachträglich signiert werden.

---

## 🛠️ Einrichtung & Lokale Ausführung

### Voraussetzungen:
- **Flutter SDK:** `3.47.x` (stable) – identisch zur in den Workflows gepinnten Version
- **Dart SDK:** Im Flutter SDK enthalten
- **Android Studio / VS Code / Xcode** mit entsprechenden Emulatoren oder Testgeräten

### Befehle:
```bash
# 1. Abhängigkeiten laden
flutter pub get

# 2. Statische Code-Analyse ausführen
flutter analyze

# 3. Unit-Tests ausführen
flutter test

# 4. App im Entwicklungsmodus starten
flutter run
```

---

## 📄 Lizenz & Urheberschaft
Entwickelt für das **Bürgerforum Oggau**. Private & gemeinnützige Verwendung.
