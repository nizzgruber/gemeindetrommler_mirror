import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isCommunityUnlocked = false;

  static const String _prefKeyUnlocked = 'community_unlocked';
  static const String defaultCommunityCode = 'oggau';

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isCommunityUnlocked => _isCommunityUnlocked;

  AuthService() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isCommunityUnlocked = prefs.getBool(_prefKeyUnlocked) ?? false;

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });

    // Automatically ensure anonymous login if unlocked
    if (_user == null && _isCommunityUnlocked) {
      await signInAnonymously();
    }
  }

  Future<bool> verifyCommunityCode(String enteredCode) async {
    final cleanCode = enteredCode.trim().toLowerCase();
    // Accept default code 'oggau' or any custom community password
    if (cleanCode == defaultCommunityCode || cleanCode == 'oggau2024' || cleanCode == 'oggau7063') {
      _isCommunityUnlocked = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyUnlocked, true);
      await signInAnonymously();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> lockCommunityAccess() async {
    _isCommunityUnlocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyUnlocked, false);
    await signOut();
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign in anonymously error: $e');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign out error: $e');
      }
    }
  }
}
