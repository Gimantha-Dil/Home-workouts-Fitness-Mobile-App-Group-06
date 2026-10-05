import '../models/user_model.dart';
import '../models/user_role.dart';
import 'api_service.dart';
import 'firebase_service.dart';

/// Central Cloud Backend Manager
/// Coordinates REST API, Firebase Firestore, and local state.
class CloudBackendManager {
  static final CloudBackendManager instance = CloudBackendManager._();
  CloudBackendManager._();

  /// Perform Cloud Login across REST API and Firebase
  Future<User?> performCloudLogin({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // 1. Try Firebase Auth
    final fbRes = await FirebaseService.signInWithEmailAndPassword(
      email: email,
      password: password,
      role: role,
    );

    // 2. Try REST API
    final apiRes = await ApiService.login(
      email: email,
      password: password,
      role: role,
    );

    final String resolvedName = email.split('@').first.replaceAll('.', ' ');
    final String capitalizedName = resolvedName.isNotEmpty
        ? resolvedName[0].toUpperCase() + resolvedName.substring(1)
        : 'FitPulse User';

    return User(
      id: apiRes['user']?['id'] ?? fbRes['uid'] ?? 'usr_cloud_${DateTime.now().millisecondsSinceEpoch}',
      name: capitalizedName,
      email: email,
      role: role,
    );
  }

  /// Perform Cloud Signup
  Future<bool> registerUserOnCloud({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final apiSuccess = await ApiService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    await FirebaseService.saveUserToFirestore(
      uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
    );

    return apiSuccess['success'] == true;
  }
}
