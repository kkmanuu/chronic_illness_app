import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chronic_illness_app/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Your actual Firebase OAuth client ID (web only)
  static const String webClientId =
      '875998740711-01dkeh6qcdlptd9a75alm5cb9hsjv28u.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Initialize GoogleSignIn safely
    _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      clientId: kIsWeb ? webClientId : null, 
    );
  }

  // ---------------- EMAIL/PASSWORD ----------------

  Future<UserModel> registerWithEmail(String email, String password, {String? name, String? role}) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification right after registration
      if (userCred.user != null && !userCred.user!.emailVerified) {
        await userCred.user!.sendEmailVerification();
        debugPrint('Email verification sent to: ${userCred.user!.email}');
      }

      // Save user to Firestore
      await saveUserToFirestore(userCred.user!, username: name, role: role);

      // Return UserModel
      final doc = await getUserFromFirestore(userCred.user!.uid);
      return UserModel.fromDocument(userCred.user!.uid, doc.data()!);
    } catch (e, st) {
      debugPrint('Register with email error: $e\n$st');
      rethrow;
    }
  }

  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user from Firestore
      final doc = await getUserFromFirestore(userCred.user!.uid);
      return UserModel.fromDocument(userCred.user!.uid, doc.data()!);
    } catch (e, st) {
      debugPrint('Login with email error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- GOOGLE SIGN-IN ----------------

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Google Sign-In: User canceled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        throw Exception(
            'Google Sign-In failed: Missing idToken or accessToken.\n'
            '➡️ Ensure SHA-1 and SHA-256 are added in Firebase Console.\n'
            '➡️ Verify OAuth client IDs in Firebase settings.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      debugPrint('Google Sign-In successful: UID ${userCred.user?.uid}');

      // Save user info in Firestore if new
      if (userCred.user != null) {
        await saveUserToFirestore(userCred.user!);
      }

      return userCred;
    } catch (e, st) {
      debugPrint('Google Sign-In error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- PASSWORD RESET ----------------

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to: $email');
    } catch (e, st) {
      debugPrint('Password reset error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- EMAIL VERIFICATION ----------------

  Future<void> sendEmailVerification(User user) async {
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Email verification sent to: ${user.email}');
      }
    } catch (e, st) {
      debugPrint('Email verification error: $e\n$st');
      rethrow;
    }
  }

  Future<void> reloadUser(User user) async {
    try {
      await user.reload();
      debugPrint('User reloaded: ${user.uid}');
    } catch (e, st) {
      debugPrint('Reload user error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- SIGN OUT ----------------

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint('User signed out');
    } catch (e, st) {
      debugPrint('Sign out error: $e\n$st');
      rethrow;
    }
  }

  // ---------------- FIRESTORE ----------------

  Future<void> saveUserToFirestore(User user, {String? username, String? role}) async {
    try {
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? 'no-email@example.com',
        role: role ?? 'user',
        username: username ?? user.displayName ?? 'Anonymous User',
      );

      debugPrint('Attempting to save user to Firestore: ${userModel.toMap()}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
      debugPrint('User successfully saved to Firestore: ${user.uid}');

      // Verify the document was created
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        throw Exception('Failed to verify user document creation in Firestore');
      }
      debugPrint('Verified user document exists: ${doc.data()}');
    } catch (e, st) {
      debugPrint('Firestore save error: $e\n$st');
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirestore(
      String uid) async {
    try {
      debugPrint('Fetching user from Firestore: UID $uid');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      debugPrint('Firestore doc exists: ${doc.exists}, Data: ${doc.data()}');
      return doc;
    } catch (e, st) {
      debugPrint('Firestore get error: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
      debugPrint('User profile updated: $uid');
    } catch (e, st) {
      debugPrint('Update user profile error: $e\n$st');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await getUserFromFirestore(user.uid);
      if (!doc.exists) return null;
      return UserModel.fromDocument(user.uid, doc.data()!);
    } catch (e, st) {
      debugPrint('Get current user error: $e\n$st');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
      debugPrint('Password updated');
    } catch (e, st) {
      debugPrint('Update password error: $e\n$st');
      rethrow;
    }
  }
}
