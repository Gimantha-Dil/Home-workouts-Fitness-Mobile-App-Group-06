import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all published workouts for Customer portal (real-time case insensitive)
  Stream<List<Workout>> getPublishedWorkouts() {
    return _firestore
        .collection('workouts')
        .snapshots()
        .map((snap) {
          final list = <Workout>[];
          for (final doc in snap.docs) {
            final data = doc.data();
            final status = (data['status'] ?? 'published').toString().toLowerCase();
            if (status == 'published' || status == 'active' || status == 'approved' || status == 'none' || status == 'draft' || status.isEmpty) {
              list.add(Workout.fromMap({'id': doc.id, ...data}));
            }
          }
          return list;
        });
  }

  /// Stream of workouts created by a specific Trainer
  Stream<List<Workout>> getTrainerWorkouts(String uid) {
    return _firestore
        .collection('workouts')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Workout.fromMap({'id': doc.id, ...doc.data()})).toList());
  }

  /// Save or update a workout document in Firestore
  Future<void> saveWorkout(Workout workout, String uid, String authorName) async {
    final docRef = workout.id.isNotEmpty
        ? _firestore.collection('workouts').doc(workout.id)
        : _firestore.collection('workouts').doc();

    final data = workout.toMap();
    data['id'] = docRef.id;
    data['createdBy'] = uid;
    data['createdByName'] = authorName;
    data['status'] = 'published';
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (!data.containsKey('createdAt')) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  /// Delete a workout document from Firestore
  Future<void> deleteWorkout(String workoutId) async {
    await _firestore.collection('workouts').doc(workoutId).delete();
  }
}
