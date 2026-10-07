import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_model.dart';
import '../models/user_role.dart';

class GoogleAuthService {
  // Replace with actual web client ID when configuring Google Cloud Console
  static const _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  static Future<User?> signInWithGoogle({
    UserRole role = UserRole.customer,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancel කළා

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google ID token එක ලැබුණේ නැහැ');
      }

      final res = await sb.Supabase.instance.client.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final sbUser = res.user;
      if (sbUser == null) return null;

      return User(
        id: sbUser.id,
        name: googleUser.displayName ?? googleUser.email.split('@')[0],
        email: googleUser.email,
        role: role,
        profilePhotoUrl: googleUser.photoUrl,
      );
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null; // fallback account එකක් නැහැ
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await sb.Supabase.instance.client.auth.signOut();
  }
}
