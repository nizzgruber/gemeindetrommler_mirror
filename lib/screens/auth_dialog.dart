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

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

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
        SnackBar(
          content: Text(
            'Konto erfolgreich erstellt! Wir haben einen Bestätigungslink an $email gesendet. Bitte prüfe dein Postfach.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
        ),
      );
    } else {
      setState(() => _errorMessage = error);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final error = await auth.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erfolgreich mit Google angemeldet!'),
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: screenHeight * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 28,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.campaign,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Bürgerforum Oggau',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                  Tab(text: 'Bürger-Code'),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
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
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Anmelden
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Column(
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
                            obscureText: _obscureLoginPassword,
                            decoration: InputDecoration(
                              labelText: 'Passwort',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureLoginPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureLoginPassword =
                                        !_obscureLoginPassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
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
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Anmelden',
                                    style: TextStyle(fontSize: 15)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'ODER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildGoogleButton(label: 'Mit Google anmelden'),
                        ],
                      ),
                    ),

                    // Tab 2: Registrierung
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _regNameController,
                            textCapitalization: TextCapitalization.words,
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
                              helperText:
                                  'Erhält einen Bestätigungslink zur Prüfung',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regPasswordController,
                            obscureText: _obscureRegPassword,
                            decoration: InputDecoration(
                              labelText: 'Passwort (mind. 6 Zeichen)',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureRegPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureRegPassword = !_obscureRegPassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _regConfirmPasswordController,
                            obscureText: _obscureRegConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Passwort bestätigen',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureRegConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureRegConfirmPassword =
                                        !_obscureRegConfirmPassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text(
                                    'Konto erstellen & E-Mail bestätigen',
                                    style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'ODER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildGoogleButton(label: 'Mit Google registrieren'),
                        ],
                      ),
                    ),

                    // Tab 3: Bürger-Code
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: const Text(
                              'Du möchtest kein persönliches E-Mail-Konto anlegen? Gib einfach den Zugangscode des Bürgerforums ein (z.B. oggau), um sofort Mängel und Ideen melden zu können.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Bürger-Zugangscode',
                              prefixIcon: Icon(Icons.key_outlined),
                              border: OutlineInputBorder(),
                              hintText: 'z.B. oggau',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleCodeUnlock,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Freischalten',
                                    style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton({required String label}) {
    return OutlinedButton(
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGoogleIcon(),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}
