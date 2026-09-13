import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AuthState extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthState() {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        _user = null;
      } else {
        print('User is signed in!');
        _user = user;
      }
      notifyListeners();
    });
  }

  Future<void> signInAnonymously() async {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
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
              onPressed: authState.user == null
                  ? authState.signInAnonymously
                  : authState.signOut,
              child: Text(authState.user == null ? 'Anonym anmelden' : 'Abmelden'),
            );
          },
        ),
      ),
    );
  }
}
