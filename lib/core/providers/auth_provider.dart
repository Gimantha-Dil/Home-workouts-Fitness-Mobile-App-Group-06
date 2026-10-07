import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/cloud_backend_manager.dart';
import '../services/google_auth_service.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _onboardingSeen = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get onboardingSeen => _onboardingSeen;

  void completeOnboarding() {
    _onboardingSeen = true;
    notifyListeners();
  }

  void login({
    required String email,
    UserRole role = UserRole.customer,
    String password = 'password123',
    String? name,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final isSuperAdmin = cleanEmail == 'gimantha333@gmail.com';
    final targetRole = isSuperAdmin ? UserRole.admin : role;

    final isGuest = cleanEmail.contains('guest');
    if (isGuest) {
      _onboardingSeen = true;
    }

    // Connect to Cloud Backend Services
    final cloudUser = await CloudBackendManager.instance.performCloudLogin(
      email: cleanEmail,
      password: password,
      role: targetRole,
    );

    final resolvedName = (name != null && name.isNotEmpty)
        ? name
        : (isSuperAdmin
            ? 'Gimantha (Super Admin)'
            : isGuest
                ? 'Guest ${targetRole.label}'
                : (cloudUser?.name ?? _nameForRole(targetRole)));

    _currentUser = User(
      id: isSuperAdmin ? 'usr_superadmin' : (cloudUser?.id ?? 'u_${targetRole.name}'),
      name: resolvedName,
      email: cleanEmail,
      role: targetRole,
    );

    // Save user record to Supabase PostgreSQL database
    await SupabaseService.saveUserToSupabase(
      uid: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      role: _currentUser!.role,
    );

    notifyListeners();
  }

  Future<bool> loginWithGoogle({UserRole role = UserRole.customer}) async {
    final user = await GoogleAuthService.signInWithGoogle(role: role);
    if (user == null) return false;

    _currentUser = user;

    await SupabaseService.saveUserToSupabase(
      uid: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    );

    notifyListeners();
    return true;
  }

  void updateProfilePhoto(String url) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePhotoUrl: url);
      SupabaseService.saveUserToSupabase(
        uid: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: _currentUser!.role,
      );
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  String _nameForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Nethmi Silva';
      case UserRole.trainer:
        return 'Alex Carter';
      case UserRole.advisor:
        return 'Dr. Silva';
      case UserRole.admin:
        return 'Gimantha (Super Admin)';
    }
  }
}
