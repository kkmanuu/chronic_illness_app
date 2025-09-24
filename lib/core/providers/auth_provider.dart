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
    _user = await _authService.loginWithEmail(email, password);
    await _loadCustomClaims();
    notifyListeners();
  }

  /// Register a new user
  Future<void> register(String email, String password, String name, String role) async {
    _user = await _authService.registerWithEmail(email, password, name: name, role: role);
    await _loadCustomClaims();
    notifyListeners();
  }

  /// Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
    notifyListeners();
  }

  /// Update profile (name + notifications + photoURL)
  Future<void> updateProfile(String name, bool notificationsEnabled, {String? photoURL}) async {
    if (_user != null) {
      await _authService.updateUserProfile(_user!.uid, {
        'username': name,
        'notificationsEnabled': notificationsEnabled,
        if (photoURL != null) 'photoURL': photoURL,
      });

      // Update local copy
      _user = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        role: _user!.role,
        username: name,
        notificationsEnabled: notificationsEnabled,
        photoURL: photoURL ?? _user!.photoURL,
      );

      notifyListeners();
    }
  }

  /// Load the currently logged-in user
  Future<void> loadCurrentUser() async {
    _user = await _authService.getCurrentUser();
    await _loadCustomClaims();
    notifyListeners();
  }

  /// Upgrade user to premium
  Future<void> upgradeToPremium() async {
    if (_user != null) {
      await _authService.updateUserProfile(_user!.uid, {'role': 'premium'});
      _user = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        role: 'premium',
        username: _user!.username,
        notificationsEnabled: _user!.notificationsEnabled,
        photoURL: _user!.photoURL,
      );
      notifyListeners();
    }
  }

  /// 🔑 Check and apply custom claims (like isAdmin)
  Future<void> _loadCustomClaims() async {
    final fb.User? firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (_user != null && firebaseUser != null) {
      final idTokenResult = await firebaseUser.getIdTokenResult(true);

      // If user has isAdmin claim, override role to 'admin'
      if (idTokenResult.claims?['isAdmin'] == true) {
        _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          role: 'admin',
          username: _user!.username,
          notificationsEnabled: _user!.notificationsEnabled,
          photoURL: _user!.photoURL,
        );
      }
    }
  }
}
