import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/mock_data.dart';
import '../models/workout_model.dart';
import '../repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repo = WorkoutRepository();
  StreamSubscription<List<Workout>>? _sub;

  List<Workout> _publishedWorkouts = [];
  bool _isLoading = true;

  List<Workout> get publishedWorkouts {
    if (_publishedWorkouts.isEmpty && kUseDemoFallback) {
      return MockData.workouts;
    }
    return _publishedWorkouts;
  }

  bool get isLoading => _isLoading;

  WorkoutProvider() {
    _initStream();
  }

  void _initStream() {
    _sub = _repo.getPublishedWorkouts().listen(
          (list) {
        _publishedWorkouts = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void cancelSubscription() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    cancelSubscription();
    super.dispose();
  }
}
