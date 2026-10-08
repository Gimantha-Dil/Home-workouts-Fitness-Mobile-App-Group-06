import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/workout_model.dart';
import '../../core/models/workout_session.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/circular_timer.dart';
import '../../shared/widgets/common_widgets.dart';
import 'rest_timer_screen.dart';
import 'workout_completed_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final int exerciseIndex;
  final WorkoutSession? session;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
    this.exerciseIndex = 0,
    this.session,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> with WidgetsBindingObserver {
  late WorkoutSession _session;
  late int _exerciseSeconds;

  int _remaining = 45;
  DateTime? _endAt;
  int _repsDone = 0;
  Timer? _timer;
  bool _paused = false;
  bool _autoCompleted = false;

  Exercise get _exercise {
    return _session.currentExercise ??
        const Exercise(id: 'fallback', name: 'Exercise', restSeconds: 15, sets: 3, reps: 10);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _session = widget.session ?? WorkoutSession(workout: widget.workout, exerciseIndex: widget.exerciseIndex);

    if (!_session.workout.hasExercises || _session.currentExercise == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This workout has no exercises yet.')),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }

    _exerciseSeconds = _exercise.restSeconds > 0 ? _exercise.restSeconds : 45;
    _remaining = _exerciseSeconds;
    _repsDone = 0; // Starts at 0 for every set

    _startTimer();
  }

  void _startTimer() {
    _endAt = DateTime.now().add(Duration(seconds: _remaining));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (_paused || _endAt == null) return;
      final now = DateTime.now();
      final diff = _endAt!.difference(now).inSeconds;

      if (diff <= 0) {
        _timer?.cancel();
        if (mounted) {
          setState(() => _remaining = 0);
          if (!_autoCompleted) {
            _autoCompleted = true;
            HapticFeedback.mediumImpact();
            _completeSet();
          }
        }
      } else {
        if (diff != _remaining && mounted) {
          setState(() => _remaining = diff);
        }
      }
    });
  }

  void _pauseTimer() {
    if (_paused) return;
    setState(() => _paused = true);
    _timer?.cancel();
  }

  void _resumeTimer() {
    if (!_paused) return;
    setState(() => _paused = false);
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed && !_paused) {
      _resumeTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _completeSet() {
    _timer?.cancel();
    if (_session.workout.exercises.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    _session.completeSet(
      repsDone: _repsDone,
      durationSeconds: _exerciseSeconds - _remaining,
    );

    final isFinished = _session.next();

    if (isFinished) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkoutCompletedScreen(workout: _session.workout, session: _session),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RestTimerScreen(
            workout: _session.workout,
            session: _session,
            nextExerciseIndex: _session.exerciseIndex,
            nextExerciseName: _session.currentExercise?.name ?? 'Next Exercise',
            restSeconds: _exercise.restSeconds,
          ),
        ),
      );
    }
  }

  void _goPrevious() {
    _timer?.cancel();
    final canGoBack = _session.previous();
    if (canGoBack) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreen(
            workout: _session.workout,
            exerciseIndex: _session.exerciseIndex,
            session: _session,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already at the first set of the first exercise.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.workout.hasExercises || _session.currentExercise == null) {
      return const SizedBox.shrink();
    }

    final total = _session.workout.exercises.length;
    final maxReps = _exercise.reps * 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text('CIRCUIT 1 • ${_session.workout.title}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(20)),
            child: Text('${_session.exerciseIndex + 1} / $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: LinearProgressIndicator(
                value: (_session.exerciseIndex + 1) / total,
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: const Color(0xFFE5E7EB),
                color: AppColors.brandTeal,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Active Form Demo Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.black87,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.65,
                              child: AppNetworkImage(
                                url: _session.workout.imageUrl,
                                height: 180,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Active Form Demo', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const Positioned(
                            top: 12,
                            right: 12,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.volume_up, color: Colors.white, size: 14),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.brandTeal, borderRadius: BorderRadius.circular(8)),
                              child: Text(_session.workout.goal.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${_session.workout.level.toUpperCase()} ROUTINE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(_exercise.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${_exercise.sets} sets • ${_exercise.reps} reps target', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 20),
                  // Circular Timer
                  CircularTimer(
                    totalSeconds: _exerciseSeconds,
                    remainingSeconds: _remaining,
                    label: 'INTERVAL ACTIVE',
                    color: AppColors.brandTeal,
                  ),
                  const SizedBox(height: 20),
                  // Sets & Reps Counter Card
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('CURRENT SET', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('${_session.currentSet}/${_exercise.sets}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('REPS DONE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_repsDone > 0) setState(() => _repsDone--);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('$_repsDone/${_exercise.reps}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_repsDone < maxReps) setState(() => _repsDone++);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: AppColors.brandTeal, shape: BoxShape.circle),
                                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Navigation Controls & Next Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: AppColors.textSecondary),
                    onPressed: _goPrevious,
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.brandTeal,
                    child: IconButton(
                      icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                      onPressed: () {
                        if (_paused) {
                          _resumeTimer();
                        } else {
                          _pauseTimer();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: AppColors.textSecondary),
                    onPressed: _completeSet,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(label: 'Next →', onPressed: _completeSet),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
