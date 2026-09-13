import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth_dialog.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bürgerforum Oggau'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Bürgerforum Logo & Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bürgerforum Oggau',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unabhängige Bürgerliste für Oggau am Neusiedler See',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Bürgerforum Access & Account Card
          Card(
            color: auth.isRegisteredUser
                ? Colors.green.shade50
                : auth.isCommunityUnlocked
                    ? Colors.teal.shade50
                    : Colors.blue.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        auth.isRegisteredUser
                            ? Icons.account_circle
                            : auth.isCommunityUnlocked
                                ? Icons.verified_user
                                : Icons.lock_outline,
                        color: auth.isRegisteredUser
                            ? Colors.green.shade700
                            : auth.isCommunityUnlocked
                                ? Colors.teal.shade800
                                : Colors.blue.shade800,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isRegisteredUser
                                  ? (auth.displayName?.isNotEmpty == true
                                      ? auth.displayName!
                                      : 'Bürger-Konto')
                                  : auth.isCommunityUnlocked
                                      ? 'Bürgerzugang: Aktiv (Code)'
                                      : 'Gastmodus (Nur Lesen)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.isRegisteredUser
                                  ? auth.email ?? 'Angemeldet'
                                  : auth.isCommunityUnlocked
                                      ? 'Mängel & Ideen freigeschaltet'
                                      : 'Anmelden oder Code eingeben zum Mitwirken.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          if (auth.isRegisteredUser || auth.isCommunityUnlocked) {
                            auth.lockCommunityAccess();
                          } else {
                            AuthDialog.show(context);
                          }
                        },
                        child: Text(
                          (auth.isRegisteredUser || auth.isCommunityUnlocked)
                              ? 'Abmelden'
                              : 'Anmelden',
                        ),
                      ),
                    ],
                  ),
                  if (!auth.isRegisteredUser && auth.isCommunityUnlocked) ...[
                    const Divider(height: 16),
                    InkWell(
                      onTap: () => AuthDialog.show(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add,
                                size: 16, color: Colors.blue.shade800),
                            const SizedBox(width: 6),
                            Text(
                              'Persönliches Konto anlegen für dauerhaften Login',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // About Bürgerforum Oggau
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.campaign, color: Colors.blue.shade800, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Über das Bürgerforum Oggau',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Das Bürgerforum Oggau ist eine unabhängige Bürgerliste für unsere Marktgemeinde Oggau am Neusiedler See.\n\n'
                    'Wir stehen für Bürgernähe, Transparenz und eine zukunftsorientierte Gemeindepolitik. '
                    'Mit dieser App (unserem digitalen „Gemeindetrommler“) wollen wir allen Bürgerinnen und Bürgern eine unkomplizierte Möglichkeit geben, Mängel im Ort aufzuzeigen, Ideen einzubringen und sich zu informieren.',
                    style: TextStyle(fontSize: 13, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Gemeindevertretung & Team Bürgerforum',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Gemeinde Bürgerservice (Nützliche Kontakte)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gemeindeamt & Bürgerservice Oggau',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Adresse: Hauptstraße 52, 7063 Oggau', style: TextStyle(fontSize: 13)),
                  Text('Telefon: +43 2685 7201', style: TextStyle(fontSize: 13)),
                  Text('Web: www.oggau.at', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 8),
                  Text(
                    'Öffnungszeiten Gemeindeamt:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text('Mo – Fr: 08:00 – 12:00 Uhr | Di zusätzlich: 13:00 – 17:00 Uhr',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Wichtige Notrufnummern
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wichtige Notrufnummern',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Feuerwehr'),
                      Text('122', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Polizei'),
                      Text('133', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rettung / Notarzt'),
                      Text('144', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Euronotruf'),
                      Text('112', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Impressum
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Impressum',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Medieninhaber & Herausgeber:\n'
                    'Bürgerforum Oggau (Unabhängige Bürgerliste Oggau)\n'
                    '7063 Oggau am Neusiedler See\n\n'
                    'Zweck der App:\n'
                    'Informations- und Mitmach-Plattform für Bürgerinnen und Bürger der Marktgemeinde Oggau am Neusiedler See.',
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
