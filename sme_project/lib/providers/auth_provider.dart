// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  String? get userId => _user?.uid;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signUpWithEmail(email, password, displayName);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signInWithEmail(email, password);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signInWithGoogle();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordReset(email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);
      _clearError();

      // Reauthenticate before deleting
      if (_user?.providerData.first.providerId == 'password') {
        await _authService.reauthenticateWithEmail(password);
      }

      await _authService.deleteAccount();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _user?.emailVerified ?? false;

  // Get auth provider (email, google, etc.)
  String get authProvider {
    if (_user?.providerData.isEmpty ?? true) return 'unknown';
    return _user!.providerData.first.providerId;
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      await _user?.reload();
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _status = loading ? AuthStatus.loading : _status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }
}