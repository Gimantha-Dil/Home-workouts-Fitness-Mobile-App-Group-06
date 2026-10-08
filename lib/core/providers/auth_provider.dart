import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;
  bool _onboardingSeen = false;
  StreamSubscription? _userSub;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get onboardingSeen => _onboardingSeen;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
    } catch (_) {}

    fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
      if (fbUser != null) {
        await refreshUserFromFirestore(fbUser);
      } else {
        _userSub?.cancel();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> refreshUserFromFirestore(fb.User fbUser) async {
    _userSub?.cancel();
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(fbUser.uid)
        .snapshots()
        .listen((snap) {
      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        _currentUser = User.fromJson(data);
      } else {
        final cleanEmail = fbUser.email?.toLowerCase() ?? '';
        final isSuperAdmin = cleanEmail == 'gimantha333@gmail.com';
        _currentUser = User(
          id: fbUser.uid,
          name: fbUser.displayName ?? (isSuperAdmin ? 'Gimantha (Admin)' : 'FitPulse User'),
          email: cleanEmail,
          role: isSuperAdmin ? UserRole.admin : UserRole.customer,
          profilePhotoUrl: fbUser.photoURL,
        );
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> completeOnboarding() async {
    _onboardingSeen = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
    } catch (_) {}
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    String? password,
    UserRole? role,
    String? name,
  }) async {
    if (password != null && password.isNotEmpty) {
      return loginWithEmail(email: email, password: password);
    }

    _isLoading = true;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();
    final isSuperAdmin = cleanEmail == 'gimantha333@gmail.com';
    final targetRole = isSuperAdmin ? UserRole.admin : (role ?? UserRole.customer);

    _currentUser = User(
      id: isSuperAdmin ? 'usr_superadmin' : 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? (isSuperAdmin ? 'Gimantha (Super Admin)' : cleanEmail.split('@').first),
      email: cleanEmail,
      role: targetRole,
    );
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signInWithEmail(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
      }
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await AuthService.sendPasswordReset(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfilePhoto(String photoUrl) async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
          'photoUrl': photoUrl,
        }, SetOptions(merge: true));

        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(profilePhotoUrl: photoUrl);
          notifyListeners();
        }
        return null;
      } catch (e) {
        return e.toString();
      }
    }
    return 'No authenticated user.';
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.signOut();

    _userSub?.cancel();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
