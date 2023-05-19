import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AuthState extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  Future<void> signInAnonymously() async {
    try {
      await auth.signInAnonymously();
      _isSignedIn = true;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    _isSignedIn = false;
    notifyListeners();
  }
}
class AnonymAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AuthState>(
          builder: (context, authState, child) {
            return ElevatedButton(
              onPressed: authState.isSignedIn
                  ? authState.signOut
                  : authState.signInAnonymously,
              child: Text(authState.isSignedIn ? 'Abmelden' : 'Anonym anmelden'),
            );
          },
        ),
      ),
    );
  }
}
