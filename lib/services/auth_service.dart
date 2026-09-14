import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isCommunityUnlocked = false;

  static const String _prefKeyUnlocked = 'community_unlocked';
  static const String defaultCommunityCode = 'oggau';

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? true;
  bool get isRegisteredUser => _user != null && !_user!.isAnonymous;
  bool get isCommunityUnlocked => _isCommunityUnlocked || isRegisteredUser;
  String? get email => _user?.email;
  String? get displayName => _user?.displayName;

  String? _cachedFirstName;
  String? _cachedLastName;
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  String get firstName {
    if (_cachedFirstName != null && _cachedFirstName!.isNotEmpty) {
      return _cachedFirstName!;
    }
    final name = _user?.displayName ?? '';
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  String get lastName {
    if (_cachedLastName != null && _cachedLastName!.isNotEmpty) {
      return _cachedLastName!;
    }
    final name = _user?.displayName ?? '';
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  AuthService() {
    _initAuth();
  }

  Future<void> _checkAdminClaim(User? user) async {
    if (user != null && !user.isAnonymous) {
      try {
        // 1. Custom claims check (token.admin == true)
        final tokenResult = await user.getIdTokenResult();
        if (tokenResult.claims?['admin'] == true) {
          _isAdmin = true;
          return;
        }

        final firestore = FirebaseFirestore.instance;

        // 2. Check Firestore 'Admins' collection by user UID (doc id)
        final docByUid =
            await firestore.collection('Admins').doc(user.uid).get();
        if (docByUid.exists) {
          _isAdmin = true;
          return;
        }

        // 3. Check Firestore 'Admins' collection by email (doc id)
        final userEmail = user.email?.trim().toLowerCase();
        if (userEmail != null && userEmail.isNotEmpty) {
          final docByEmail =
              await firestore.collection('Admins').doc(userEmail).get();
          if (docByEmail.exists) {
            _isAdmin = true;
            return;
          }

          // 4. Check Firestore 'Admins' collection where email field == userEmail
          final queryByEmail = await firestore
              .collection('Admins')
              .where('email', isEqualTo: userEmail)
              .limit(1)
              .get();
          if (queryByEmail.docs.isNotEmpty) {
            _isAdmin = true;
            return;
          }
        }

        // 5. Check Firestore 'Admins' collection where uid field == user.uid
        final queryByUid = await firestore
            .collection('Admins')
            .where('uid', isEqualTo: user.uid)
            .limit(1)
            .get();
        if (queryByUid.docs.isNotEmpty) {
          _isAdmin = true;
          return;
        }

        _isAdmin = false;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error checking admin status: $e');
        }
        _isAdmin = false;
      }
    } else {
      _isAdmin = false;
    }
  }

  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isCommunityUnlocked = prefs.getBool(_prefKeyUnlocked) ?? false;
    _cachedFirstName = prefs.getString('user_first_name');
    _cachedLastName = prefs.getString('user_last_name');

    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      await _checkAdminClaim(user);
      notifyListeners();
    });

    if (_user == null && _isCommunityUnlocked) {
      await signInAnonymously();
    }
  }

  /// Verifies community access code
  Future<bool> verifyCommunityCode(String enteredCode) async {
    final cleanCode = enteredCode.trim().toLowerCase();
    if (cleanCode == defaultCommunityCode ||
        cleanCode == 'oggau2024' ||
        cleanCode == 'oggau7063') {
      _isCommunityUnlocked = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyUnlocked, true);
      if (_user == null) {
        await signInAnonymously();
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Lock community access and log out
  Future<void> lockCommunityAccess() async {
    _isCommunityUnlocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyUnlocked, false);
    await signOut();
    notifyListeners();
  }

  /// Sign in with Email and Password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getLocalizedErrorMessage(e.code);
    } catch (e) {
      return 'Ein unerwarteter Fehler ist aufgetreten: $e';
    }
  }

  /// Sign up with Email, Password, First Name, and Last Name
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      if (_user != null) {
        final cleanFirst = firstName.trim();
        final cleanLast = lastName.trim();
        final fullName = '$cleanFirst $cleanLast'.trim();
        if (fullName.isNotEmpty) {
          await _user!.updateDisplayName(fullName);
        }
        _cachedFirstName = cleanFirst;
        _cachedLastName = cleanLast;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_first_name', cleanFirst);
        await prefs.setString('user_last_name', cleanLast);

        // Send email verification so user verifies they own the email address
        try {
          await _user!.sendEmailVerification();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error sending verification email: $e');
          }
        }
      }
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getLocalizedErrorMessage(e.code);
    } catch (e) {
      return 'Ein unerwarteter Fehler ist aufgetreten: $e';
    }
  }

  /// Check if user's email is verified
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// Reload current user from Firebase to refresh emailVerified status and admin claim
  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _auth.currentUser;
    await _checkAdminClaim(_user);
    notifyListeners();
  }

  /// Re-send verification email
  Future<String?> sendEmailVerification() async {
    try {
      await _user?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _getLocalizedErrorMessage(e.code);
    } catch (e) {
      return 'Fehler beim Senden der Bestätigungs-E-Mail: $e';
    }
  }

  /// Sign in with Google (UI stub / preparation)
  Future<String?> signInWithGoogle() async {
    // Note: Once SHA-1 fingerprint is registered in Firebase Console,
    // the full interactive Google OAuth sign-in flow can be activated.
    return 'Google Sign-In ist in Vorbereitung. Bitte nutze derzeit die E-Mail-Anmeldung oder den Bürger-Code.';
  }

  /// Send password reset email
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getLocalizedErrorMessage(e.code);
    } catch (e) {
      return 'Fehler beim Senden der E-Mail: $e';
    }
  }

  /// Anonymous login
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign in anonymously error: $e');
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_first_name');
      await prefs.remove('user_last_name');
      _cachedFirstName = null;
      _cachedLastName = null;
      _isAdmin = false;
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign out error: $e');
      }
    }
  }

  String _getLocalizedErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Kein Benutzer mit dieser E-Mail-Adresse gefunden.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Falsches Passwort oder ungültige Anmeldedaten.';
      case 'email-already-in-use':
        return 'Diese E-Mail-Adresse wird bereits für ein Konto verwendet.';
      case 'invalid-email':
        return 'Bitte gib eine gültige E-Mail-Adresse ein.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach (mindestens 6 Zeichen erforderlich).';
      case 'too-many-requests':
        return 'Zu viele fehlgeschlagene Versuche. Bitte warte kurz.';
      case 'network-request-failed':
        return 'Keine Internetverbindung vorhanden.';
      default:
        return 'Authentifizierungsfehler ($code).';
    }
  }
}
