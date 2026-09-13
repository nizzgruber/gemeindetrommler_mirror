import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showUnlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Gemeinde-Zugang freischalten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geben Sie das Passwort bzw. den Zugangscode der Marktgemeinde Oggau ein, um Mängel zu melden und im Bürgerforum mitzuwirken.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemeinde-Passwort',
                border: OutlineInputBorder(),
                hintText: 'z.B. oggau',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              final success =
                  await auth.verifyCommunityCode(_codeController.text);
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Zugang erfolgreich freigeschaltet!'
                      : 'Ungültiges Passwort. Bitte kontaktieren Sie das Gemeindeamt.'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Freischalten'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Community Access Card
          Card(
            color: auth.isCommunityUnlocked ? Colors.green.shade50 : Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    auth.isCommunityUnlocked
                        ? Icons.verified_user
                        : Icons.lock_outline,
                    color: auth.isCommunityUnlocked ? Colors.green : Colors.blue,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isCommunityUnlocked
                              ? 'Bürgerzugang: Aktiv'
                              : 'Gastmodus (Nur Lesen)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          auth.isCommunityUnlocked
                              ? 'Sie können Mängel und Ideen einreichen.'
                              : 'Gemeinde-Passwort eingeben zum Freischalten.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (auth.isCommunityUnlocked) {
                        auth.lockCommunityAccess();
                      } else {
                        _showUnlockDialog(context);
                      }
                    },
                    child: Text(auth.isCommunityUnlocked ? 'Sperren' : 'Anmelden'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gemeinde Info Header
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marktgemeinde Oggau am Neusiedler See',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Hauptstraße 52, 7063 Oggau'),
                  Text('Telefon: +43 2685 7201'),
                  Text('E-Mail: post@oggau.bgld.gv.at'),
                  Text('Web: www.oggau.at'),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Parteienverkehr / Öffnungszeiten:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Montag bis Freitag: 08:00 – 12:00 Uhr'),
                  Text('Dienstag zusätzlich: 13:00 – 17:00 Uhr'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notrufnummern
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wichtige Notrufnummern',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Feuerwehr'),
                      Text('122', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Polizei'),
                      Text('133', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rettung / Notarzt'),
                      Text('144', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Euronotruf'),
                      Text('112', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ärztefunkdienst'),
                      Text('141', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                    'Impressum & Rechtliches',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Medieninhaber & Herausgeber:\n'
                    'Marktgemeinde Oggau am Neusiedler See\n'
                    'Hauptstraße 52, A-7063 Oggau\n\n'
                    'Erstellt als Gemeinde-Informationssystem für Bürgerinnen und Bürger.\n'
                    'Alle Rechte vorbehalten.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
