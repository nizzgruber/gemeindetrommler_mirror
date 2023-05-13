import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    // Hier kannst du deine Validierungslogik implementieren
    // Rückgabe true, wenn die E-Mail gültig ist, andernfalls false
    // Beispiel:
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Bitte geben Sie eine E-Mail-Adresse ein.';
                    } else if (!isValidEmail(value)) {
                      return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    if (isValidEmail(email)) {
                      // E-Mail ist gültig, führe die entsprechende Aktion aus
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ungültige E-Mail-Adresse'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Anmelden'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Noch kein Konto?'),
                    TextButton(
                      onPressed: () {
                        // Navigiere zur Registrierungsseite
                      },
                      child: const Text('Registrieren'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

