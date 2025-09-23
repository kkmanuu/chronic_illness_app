import 'package:flutter/material.dart';
import 'package:chronic_illness_app/core/models/user_model.dart';
import 'package:chronic_illness_app/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  AuthProvider() {
    // Listen to Firebase auth state changes
    fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? firebaseUser) async {
      if (firebaseUser != null) {
        await loadCurrentUser();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      _user = await _authService.loginWithEmail(email, password);
      await _loadCustomClaims();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Register a new user
  Future<void> register(String email, String password, String name, String role) async {
    try {
      _user = await _authService.registerWithEmail(email, password, name: name, role: role);
      await _loadCustomClaims();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update profile (name + notifications)
  Future<void> updateProfile(String name, bool notificationsEnabled) async {
    if (_user != null) {
      try {
        await _authService.updateUserProfile(_user!.uid, {
          'username': name,
          'notificationsEnabled': notificationsEnabled,
        });

        // Update local copy
        _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          role: _user!.role,
          username: name,
          notificationsEnabled: notificationsEnabled,
          photoURL: _user!.photoURL,
        );

        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Load the currently logged-in user
  Future<void> loadCurrentUser() async {
    try {
      _user = await _authService.getCurrentUser();
      await _loadCustomClaims();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Check and apply custom claims (like isAdmin)
  Future<void> _loadCustomClaims() async {
    final fb.User? firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (_user != null && firebaseUser != null) {
      try {
        final idTokenResult = await firebaseUser.getIdTokenResult(true);
        final isAdmin = idTokenResult.claims?['isAdmin'] == true;

        // Update user role if isAdmin claim is present
        if (isAdmin) {
          _user = UserModel(
            uid: _user!.uid,
            email: _user!.email,
            role: 'admin',
            username: _user!.username,
            notificationsEnabled: _user!.notificationsEnabled,
            photoURL: _user!.photoURL,
          );
        }
      } catch (e) {
        debugPrint('Error loading custom claims: $e');
        // Don't overwrite user role if claim fetch fails
      }
    }
  }
}