import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = true;
  bool _onboardingSeen = false;
  StreamSubscription<fb.User?>? _authSubscription;
  VoidCallback? onAuthStateChanged;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get onboardingSeen => _onboardingSeen;

  AuthProvider() {
    _loadOnboardingStatus();
    _initAuthListener();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingSeen = prefs.getBool('onboarding_completed') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    _onboardingSeen = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    _onboardingSeen = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_completed');
    } catch (_) {}
  }

  void _initAuthListener() {
    // Safety fallback timeout to ensure app transitions out of splash screen
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });

    _authSubscription = _auth.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        onAuthStateChanged?.call();
      } else {
        await refreshUserFromFirestore(fbUser);
        onAuthStateChanged?.call();
      }
    }, onError: (error) {
      debugPrint('Auth listener error: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Load user profile and role strictly from Firestore `users/{uid}`
  Future<void> refreshUserFromFirestore(fb.User fbUser) async {
    try {
      final docSnap = await _firestore
          .collection('users')
          .doc(fbUser.uid)
          .get()
          .timeout(const Duration(seconds: 3));

      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final roleStr = data['role'] ?? 'customer';
        final role = UserRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => UserRole.customer,
        );

        _currentUser = User(
          id: fbUser.uid,
          name: data['name'] ?? fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'User',
          email: fbUser.email ?? data['email'] ?? '',
          role: role,
          profilePhotoUrl: data['photoUrl'] ?? fbUser.photoURL,
          isProfileCompleted: data['profileCompleted'] ?? false,
        );
      } else {
        // Doc doesn't exist yet; create default customer doc
        final name = fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'User';
        final email = fbUser.email ?? '';
        await _firestore.collection('users').doc(fbUser.uid).set({
          'id': fbUser.uid,
          'name': name,
          'email': email,
          'role': 'customer',
          'verificationStatus': 'none',
          'profileCompleted': false,
          'photoUrl': fbUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _currentUser = User(
          id: fbUser.uid,
          name: name,
          email: email,
          role: UserRole.customer,
          profilePhotoUrl: fbUser.photoURL,
          isProfileCompleted: false,
        );
      }
    } catch (e) {
      debugPrint('Error loading user from Firestore: $e');
      // On network timeout or offline fallback to basic auth user info
      final name = fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'User';
      _currentUser = User(
        id: fbUser.uid,
        name: name,
        email: fbUser.email ?? '',
        role: UserRole.customer,
        profilePhotoUrl: fbUser.photoURL,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign In with Email & Password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await AuthService.signInWithEmail(email: email, password: password);
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await refreshUserFromFirestore(fbUser);
      }
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign Up with Email & Password
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await AuthService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      notifyListeners();
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign In with Google
  Future<String?> loginWithGoogle() async {
    try {
      final user = await AuthService.signInWithGoogle();
      if (user == null) {
        return 'Google Sign-In was cancelled.';
      }
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await refreshUserFromFirestore(fbUser);
      } else {
        _currentUser = user;
        notifyListeners();
      }
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// Send Password Reset Email
  Future<String?> resetPassword(String email) async {
    try {
      await AuthService.sendPasswordReset(email);
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// Update Profile Photo URL in Firestore and FirebaseAuth
  Future<String?> updateProfilePhoto(String url) async {
    if (_currentUser == null) return 'No active user session.';
    try {
      final uid = _currentUser!.id;
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': url,
      });

      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await fbUser.updatePhotoURL(url);
      }

      _currentUser = _currentUser!.copyWith(profilePhotoUrl: url);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Failed to update profile photo: $e');
      return e.toString();
    }
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.signOut();
    _currentUser = null;
    _onboardingSeen = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
