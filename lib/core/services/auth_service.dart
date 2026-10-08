import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _envWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String defaultWebClientId = '89236596610-s4o1rj10n5d3bhc5ngpt7al6cacm5tv1.apps.googleusercontent.com';

  static String get webClientId => _envWebClientId.isNotEmpty ? _envWebClientId : defaultWebClientId;

  static GoogleSignIn get _googleSignIn => GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );

  /// Helper to map FirebaseAuthException codes to friendly messages
  static String mapAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password entered. Please try again.';
      case 'invalid-credential':
        return 'Invalid email address or password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose at least 8 characters with numbers.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again in a few minutes.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }

  /// Sign Up with Email and Password
  static Future<User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        throw Exception('User creation failed: null user returned from Firebase Auth.');
      }

      await fbUser.updateDisplayName(name.trim());
      await fbUser.sendEmailVerification();

      // Create Firestore User Document (Role always defaults to customer)
      final userDocRef = _firestore.collection('users').doc(fbUser.uid);
      final userData = {
        'id': fbUser.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'customer',
        'verificationStatus': 'none',
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userDocRef.set(userData, SetOptions(merge: true));

      return User(
        id: fbUser.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: UserRole.customer,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } catch (e) {
      throw 'Sign up failed: ${e.toString()}';
    }
  }

  /// Sign In with Email and Password
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } catch (e) {
      throw 'Sign in failed: ${e.toString()}';
    }
  }

  /// Sign In with Google
  static Future<User?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (_) {
        // Fallback without serverClientId if client ID mismatch occurs on local emulator
        final fallbackSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        googleUser = await fallbackSignIn.signIn();
      }

      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      fb.AuthCredential credential;
      if (idToken != null) {
        credential = fb.GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: accessToken,
        );
      } else if (accessToken != null) {
        credential = fb.GoogleAuthProvider.credential(
          accessToken: accessToken,
        );
      } else {
        throw 'Failed to obtain Google authentication tokens from Google Play Services.';
      }

      final userCredential = await _auth.signInWithCredential(credential);
      final fbUser = userCredential.user;
      if (fbUser == null) return null;

      // Check or create Firestore document
      final userDocRef = _firestore.collection('users').doc(fbUser.uid);
      final docSnap = await userDocRef.get();

      UserRole role = UserRole.customer;
      String name = googleUser.displayName ?? fbUser.displayName ?? googleUser.email.split('@')[0];

      if (!docSnap.exists) {
        await userDocRef.set({
          'id': fbUser.uid,
          'name': name,
          'email': fbUser.email ?? googleUser.email,
          'role': 'customer',
          'verificationStatus': 'none',
          'photoUrl': googleUser.photoUrl ?? fbUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        final data = docSnap.data();
        if (data != null && data['role'] != null) {
          role = UserRole.values.firstWhere(
            (r) => r.name == data['role'],
            orElse: () => UserRole.customer,
          );
        }
      }

      return User(
        id: fbUser.uid,
        name: name,
        email: fbUser.email ?? googleUser.email,
        role: role,
        profilePhotoUrl: googleUser.photoUrl ?? fbUser.photoURL,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' || e.message?.contains('12500') == true) {
        throw 'Google Sign-In requires a Google Account signed into your Android Emulator / Phone, and SHA-1 registered in Firebase Console.';
      }
      throw 'Google Sign-In failed: ${e.message ?? e.toString()}';
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('12500') || errStr.contains('sign_in_failed')) {
        throw 'Google Sign-In requires a Google Account signed into your Android Emulator / Phone, and SHA-1 registered in Firebase Console.';
      }
      throw 'Google Sign In failed: ${e.toString()}';
    }
  }

  /// Send Password Reset Email
  static Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: ${e.toString()}';
    }
  }

  /// Sign Out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await _googleSignIn.disconnect();
    } catch (_) {}

    try {
      if (sb.Supabase.instance.client.auth.currentSession != null) {
        await sb.Supabase.instance.client.auth.signOut();
      }
    } catch (_) {}
  }
}
