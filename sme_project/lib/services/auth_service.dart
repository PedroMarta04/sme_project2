// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(
      String email,
      String password,
      String displayName,
      ) async {
    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(
          userCredential.user!,
          provider: 'email',
        );
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(
      String email,
      String password,
      ) async {
    try {
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Check if running on web
      if (kIsWeb) {
        // Use popup for web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Optional: Add custom parameters
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({
          'login_hint': 'user@example.com',
        });

        final UserCredential userCredential =
        await _auth.signInWithPopup(googleProvider);

        // Create user document if new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserDocument(
            userCredential.user!,
            provider: 'google',
          );
        }

        return userCredential;
      } else {
        // Use native flow for mobile
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw 'Google sign-in was cancelled';
        }

        // Obtain auth details from request
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with credential
        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        // Create user document if new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserDocument(
            userCredential.user!,
            provider: 'google',
          );
        }

        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google sign-in failed: ${e.toString()}';
    }
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        if (!kIsWeb) _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _deleteUserData(user.uid);

        // Delete auth account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Please sign in again to delete your account.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Reauthenticate user
  Future<void> reauthenticateWithEmail(String password) async {
    try {
      final user = _auth.currentUser;
      if (user?.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw 'Failed to verify password. Please try again.';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
      User user, {
        required String provider,
      }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'User',
        'photoURL': user.photoURL,
        'provider': provider,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'settings': {
          'baseCurrency': 'USD',
          'budgetAlerts': true,
          'theme': 'system',
          'biometricEnabled': false,
        },
      }, SetOptions(merge: true));

      // Create default categories
      await _createDefaultCategories(user.uid);
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Create default expense categories
  Future<void> _createDefaultCategories(String userId) async {
    final defaultCategories = [
      {'name': 'Food & Dining', 'icon': '🍔', 'color': 0xFFFF6B6B},
      {'name': 'Transportation', 'icon': '🚗', 'color': 0xFF4ECDC4},
      {'name': 'Shopping', 'icon': '🛍️', 'color': 0xFFFFBE0B},
      {'name': 'Entertainment', 'icon': '🎬', 'color': 0xFFFB5607},
      {'name': 'Bills & Utilities', 'icon': '💡', 'color': 0xFF8338EC},
      {'name': 'Healthcare', 'icon': '🏥', 'color': 0xFF06FFA5},
      {'name': 'Other', 'icon': '📦', 'color': 0xFF9E9E9E},
    ];

    final batch = _firestore.batch();
    for (var category in defaultCategories) {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc();
      batch.set(docRef, {
        ...category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // Delete user data from Firestore
  Future<void> _deleteUserData(String userId) async {
    try {
      // Delete all user subcollections
      final collections = ['expenses', 'budgets', 'categories'];

      for (var collection in collections) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection(collection)
            .get();

        final batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed. Please try again.';
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}