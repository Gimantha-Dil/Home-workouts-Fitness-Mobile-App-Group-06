import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class ContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of safety guidance and precautions content by category
  Stream<List<SafetyGuide>> getSafetyContent(String category) {
    return _firestore
        .collection('safetyContent')
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'Published')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return SafetyGuide(
                id: doc.id,
                title: data['title'] ?? '',
                category: data['category'] ?? category,
                content: data['body'] ?? data['content'] ?? '',
                status: data['status'] ?? 'Published',
              );
            }).toList());
  }

  /// Save or update safety content document
  Future<void> saveSafetyContent(SafetyGuide guide, String uid) async {
    final docRef = guide.id.isNotEmpty
        ? _firestore.collection('safetyContent').doc(guide.id)
        : _firestore.collection('safetyContent').doc();

    await docRef.set({
      'id': docRef.id,
      'title': guide.title,
      'category': guide.category,
      'body': guide.content,
      'status': guide.status,
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
