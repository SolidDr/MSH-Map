import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_model.dart';

/// Provider for FirebaseAuth instance (nullable für Web-Sicherheit)
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  try {
    return FirebaseAuth.instance;
  } catch (e) {
    debugPrint('FirebaseAuth init error: $e');
    return null;
  }
});

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth);
});

/// Repository handling authentication operations
class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth? _auth;

  /// Prüft ob Auth verfügbar ist
  bool get isAvailable => _auth != null;

  /// Get current user stream (leerer Stream wenn Auth nicht verfügbar)
  Stream<UserModel?> get authStateChanges {
    final auth = _auth;
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
      final auth = _auth;
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
    final auth = _auth;
    if (auth == null) return null;
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
  }

  /// Register with email and password
  Future<UserModel?> registerWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;
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
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth?.signOut();
  }
}
