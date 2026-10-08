import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Aggregate counts for Admin Dashboard
  Future<Map<String, int>> getAggregateCounts() async {
    try {
      final userSnap = await _firestore.collection('users').count().get();
      final workoutSnap = await _firestore.collection('workouts').where('status', isEqualTo: 'Published').count().get();
      final verificationSnap = await _firestore.collection('verificationRequests').where('status', isEqualTo: 'pending').count().get();

      return {
        'totalUsers': userSnap.count ?? 0,
        'publishedWorkouts': workoutSnap.count ?? 0,
        'pendingVerifications': verificationSnap.count ?? 0,
      };
    } catch (_) {
      return {
        'totalUsers': 0,
        'publishedWorkouts': 0,
        'pendingVerifications': 0,
      };
    }
  }
}
