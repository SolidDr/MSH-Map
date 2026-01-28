import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_model.dart';

/// Provider for the auth repository
/// HINWEIS: Firebase Auth wurde deaktiviert (verursacht JS-Fehler auf Web)
/// Auth-Features werden aktuell nicht genutzt
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Repository handling authentication operations
/// STUB: Firebase Auth ist deaktiviert, alle Methoden geben null/false zurück
class AuthRepository {
  AuthRepository();

  /// Prüft ob Auth verfügbar ist (immer false - Auth deaktiviert)
  bool get isAvailable => false;

  /// Get current user stream (immer null - Auth deaktiviert)
  Stream<UserModel?> get authStateChanges => Stream.value(null);

  /// Get current user (immer null - Auth deaktiviert)
  UserModel? get currentUser => null;

  /// Sign in with email and password (deaktiviert)
  Future<UserModel?> signInWithEmail(String email, String password) async {
    debugPrint('Auth deaktiviert: signInWithEmail nicht verfügbar');
    return null;
  }

  /// Register with email and password (deaktiviert)
  Future<UserModel?> registerWithEmail(String email, String password) async {
    debugPrint('Auth deaktiviert: registerWithEmail nicht verfügbar');
    return null;
  }

  /// Sign out (deaktiviert)
  Future<void> signOut() async {
    debugPrint('Auth deaktiviert: signOut nicht verfügbar');
  }
}
