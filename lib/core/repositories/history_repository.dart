import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of completed workout history for a user
  Stream<List<Map<String, dynamic>>> getUserHistory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Add completed workout history entry
  Future<void> addHistoryEntry(String uid, Map<String, dynamic> entry) async {
    final docRef = _firestore.collection('users').doc(uid).collection('history').doc();
    final data = Map<String, dynamic>.from(entry);
    data['id'] = docRef.id;
    data['completedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
  }
}
