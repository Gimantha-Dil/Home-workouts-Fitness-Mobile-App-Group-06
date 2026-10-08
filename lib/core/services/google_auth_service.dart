import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static Future<User?> signInWithGoogle({UserRole role = UserRole.customer}) async {
    return AuthService.signInWithGoogle();
  }

  static Future<User?> handleGoogleSignIn({
    BuildContext? context,
    UserRole role = UserRole.customer,
  }) async {
    return AuthService.signInWithGoogle();
  }

  static Future<void> signOut() async {
    await AuthService.signOut();
  }
}
