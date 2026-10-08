import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all published workouts for Customer portal
  Stream<List<Workout>> getPublishedWorkouts() {
    return _firestore
        .collection('workouts')
        .where('status', isEqualTo: 'Published')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Workout.fromMap({'id': doc.id, ...doc.data()})).toList());
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
