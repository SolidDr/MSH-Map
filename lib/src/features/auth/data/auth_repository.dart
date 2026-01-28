import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_model.dart';

/// Provider for the auth repository (lazy initialization)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Repository handling authentication operations
/// Firebase Auth wird erst bei Bedarf initialisiert (lazy)
class AuthRepository {
  AuthRepository();

  // Lazy initialized Firebase Auth
  FirebaseAuth? _auth;
  bool _initAttempted = false;

  /// Lazy initialization von Firebase Auth
  FirebaseAuth? _getAuth() {
    if (_initAttempted) return _auth;
    _initAttempted = true;

    try {
      // Auf Web: Nur initialisieren wenn explizit angefordert
      // Das verhindert den frühen Listener-Fehler
      if (kIsWeb) {
        debugPrint('FirebaseAuth: Skipping auto-init on web');
        return null;
      }
      _auth = FirebaseAuth.instance;
      return _auth;
    } catch (e) {
      debugPrint('FirebaseAuth init error: $e');
      return null;
    }
  }

  /// Explizite Initialisierung für Login (nur aufrufen wenn User einloggen will)
  Future<FirebaseAuth?> initializeAuth() async {
    if (_auth != null) return _auth;

    try {
      _auth = FirebaseAuth.instance;
      _initAttempted = true;
      return _auth;
    } catch (e) {
      debugPrint('FirebaseAuth explicit init error: $e');
      return null;
    }
  }

  /// Prüft ob Auth verfügbar ist
  bool get isAvailable => _getAuth() != null;

  /// Get current user stream (leerer Stream wenn Auth nicht verfügbar)
  Stream<UserModel?> get authStateChanges {
    final auth = _getAuth();
    if (auth == null) return Stream.value(null);
    try {
      return auth.authStateChanges().map((user) {
        if (user == null) return null;
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }).handleError((Object error) {
        debugPrint('Auth state error: $error');
        return null;
      });
    } catch (e) {
      debugPrint('Auth stream error: $e');
      return Stream.value(null);
    }
  }

  /// Get current user (null wenn Auth nicht verfügbar)
  UserModel? get currentUser {
    try {
      final auth = _getAuth();
      if (auth == null) return null;
      final user = auth.currentUser;
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      // Firebase Auth noch nicht bereit
      return null;
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    // Explizit initialisieren beim Login-Versuch
    final auth = await initializeAuth();
    if (auth == null) return null;

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Register with email and password
  Future<UserModel?> registerWithEmail(String email, String password) async {
    // Explizit initialisieren beim Registrierungs-Versuch
    final auth = await initializeAuth();
    if (auth == null) return null;

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
      );
    } catch (e) {
      debugPrint('Register error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth?.signOut();
  }
}
