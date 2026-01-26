import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/user_model.dart';

/// Authentication state
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Auth controller provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

/// Controller managing authentication state
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthInitial());

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _repository.signInWithEmail(email, password);
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthError('Anmeldung fehlgeschlagen');
      }
    } on Exception catch (e) {
      state = AuthError('Fehler: $e');
    }
  }

  /// Register with email and password
  Future<void> register(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _repository.registerWithEmail(email, password);
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthError('Registrierung fehlgeschlagen');
      }
    } on Exception catch (e) {
      state = AuthError('Fehler: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _repository.signOut();
      state = const AuthUnauthenticated();
    } on Exception catch (e) {
      state = AuthError('Fehler beim Abmelden: $e');
    }
  }
}
