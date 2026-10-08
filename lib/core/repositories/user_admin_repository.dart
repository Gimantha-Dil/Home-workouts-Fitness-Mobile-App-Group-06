import 'package:cloud_firestore/cloud_firestore.dart';

class UserAdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream users filtered by role with limit 50
  Stream<List<Map<String, dynamic>>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Stream pending trainer & advisor verification requests
  Stream<List<Map<String, dynamic>>> getPendingVerifications() {
    return _firestore
        .collection('verificationRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
