import '../models/user_model.dart';
import '../models/user_role.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static Future<User?> signInWithGoogle() async {
    return AuthService.signInWithGoogle();
  }

  static Future<User?> handleGoogleSignIn({dynamic context, UserRole? role}) async {
    return AuthService.signInWithGoogle();
  }

  static Future<void> signOut() async {
    await AuthService.signOut();
  }
}
