import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => const AuthDialog(),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  // Code Controller
  final _codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Bitte E-Mail und Passwort eingeben.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final error = await auth.signInWithEmail(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erfolgreich angemeldet!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _errorMessage = error);
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final confirm = _regConfirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Bitte alle Pflichtfelder ausfüllen.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'Die Passwörter stimmen nicht überein.');
      return;
    }

    if (password.length < 6) {
      setState(
          () => _errorMessage = 'Das Passwort muss mindestens 6 Zeichen lang sein.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final error = await auth.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konto erfolgreich erstellt! Willkommen im Bürgerforum.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _errorMessage = error);
    }
  }

  Future<void> _handleCodeUnlock() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Bitte den Zugangscode eingeben.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.verifyCommunityCode(code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bürgerzugang freigeschaltet!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _errorMessage =
          'Ungültiger Zugangscode. Bitte wende dich an das Bürgerforum.');
    }
  }

  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController(
      text: _loginEmailController.text,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Passwort zurücksetzen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gib deine E-Mail-Adresse ein. Wir senden dir einen Link, mit dem du ein neues Passwort festlegen kannst.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-Mail-Adresse',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              final auth = Provider.of<AuthService>(context, listen: false);
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              final err = await auth.sendPasswordReset(email);
              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(err ?? 'E-Mail zum Zurücksetzen wurde versendet!'),
                  backgroundColor: err == null ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Link senden'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bürgerforum Oggau',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue.shade800,
                indicatorColor: Colors.blue.shade800,
                tabs: const [
                  Tab(text: 'Anmelden'),
                  Tab(text: 'Registrieren'),
                  Tab(text: 'Code-Login'),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: 280,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Login
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _loginEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-Mail-Adresse',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _loginPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Passwort',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showPasswordResetDialog,
                                child: const Text(
                                  'Passwort vergessen?',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Anmelden'),
                            ),
                          ],
                        ),

                        // Tab 2: Registrierung
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _regNameController,
                              decoration: const InputDecoration(
                                labelText: 'Name / Vorname',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _regEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-Mail-Adresse',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _regPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Passwort (mind. 6 Zeichen)',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _regConfirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Passwort bestätigen',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Konto erstellen'),
                            ),
                          ],
                        ),

                        // Tab 3: Bürger-Code
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Du möchtest kein persönliches Konto anlegen? Gib einfach den Zugangscode des Bürgerforums ein, um sofort Mängel und Ideen melden zu können.',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _codeController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Bürger-Zugangscode',
                                prefixIcon: Icon(Icons.key_outlined),
                                border: OutlineInputBorder(),
                                hintText: 'z.B. oggau',
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleCodeUnlock,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Freischalten'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
