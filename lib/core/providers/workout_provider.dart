import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/mock_data.dart';
import '../models/workout_model.dart';
import '../repositories/workout_repository.dart';
import '../services/supabase_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repo = WorkoutRepository();
  StreamSubscription<List<Workout>>? _firestoreSub;
  StreamSubscription<List<Workout>>? _supabaseSub;

  List<Workout> _firestoreWorkouts = [];
  List<Workout> _supabaseWorkouts = [];
  bool _isLoading = true;

  List<Workout> get publishedWorkouts {
    final map = <String, Workout>{};

    // 1. Add Supabase workouts
    for (final w in _supabaseWorkouts) {
      if (w.title.isNotEmpty) {
        map[w.id] = w;
      }
    }

    // 2. Add Firestore workouts (takes precedence if same ID)
    for (final w in _firestoreWorkouts) {
      if (w.title.isNotEmpty) {
        map[w.id] = w;
      }
    }

    final combined = map.values.toList();
    if (combined.isEmpty && kUseDemoFallback) {
      return MockData.workouts;
    }
    return combined;
  }

  bool get isLoading => _isLoading;

  WorkoutProvider() {
    _initStream();
  }

  void _initStream() {
    // 1. Real-time Firestore Stream
    _firestoreSub = _repo.getPublishedWorkouts().listen(
      (list) {
        _firestoreWorkouts = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );

    // 2. Real-time Supabase Database Stream
    try {
      _supabaseSub = SupabaseService.streamWorkoutsFromSupabase().listen(
        (list) {
          _supabaseWorkouts = list;
          _isLoading = false;
          notifyListeners();
        },
        onError: (_) {
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (_) {}
  }

  void cancelSubscription() {
    _firestoreSub?.cancel();
    _supabaseSub?.cancel();
    _firestoreSub = null;
    _supabaseSub = null;
  }

  @override
  void dispose() {
    cancelSubscription();
    super.dispose();
  }
}
