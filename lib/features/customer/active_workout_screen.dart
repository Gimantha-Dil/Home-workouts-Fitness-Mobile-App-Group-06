import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/circular_timer.dart';
import '../../shared/widgets/common_widgets.dart';
import 'rest_timer_screen.dart';
import 'workout_completed_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final int exerciseIndex;
  const ActiveWorkoutScreen({super.key, required this.workout, this.exerciseIndex = 0});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  static const _exerciseSeconds = 45;
  int _remaining = _exerciseSeconds;
  int _currentSet = 1;
  int _repsDone = 5;
  Timer? _timer;
  bool _paused = false;

  Exercise get _exercise => widget.workout.exercises[widget.exerciseIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_paused) return;
      if (_remaining <= 0) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    _timer?.cancel();
    final isLast = widget.exerciseIndex >= widget.workout.exercises.length - 1;
    if (isLast) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WorkoutCompletedScreen(workout: widget.workout)),
      );
    } else {
      final next = widget.workout.exercises[widget.exerciseIndex + 1];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RestTimerScreen(
            workout: widget.workout,
            nextExerciseIndex: widget.exerciseIndex + 1,
            nextExerciseName: next.name,
            restSeconds: _exercise.restSeconds,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.workout.exercises.length;
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
        title: Text('CIRCUIT 1 • ${widget.workout.title}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(20)),
            child: Text('${widget.exerciseIndex + 1} / $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: LinearProgressIndicator(
                value: (widget.exerciseIndex + 1) / total,
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
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                        opacity: 0.65,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Active Form Demo', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: const Icon(Icons.volume_up, color: Colors.white, size: 14),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.brandTeal, borderRadius: BorderRadius.circular(8)),
                            child: const Text('CHEST & CORE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('UPPER BODY TONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
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
                              Text('$_currentSet/${_exercise.sets}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
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
                                    onTap: () => setState(() => _repsDone++),
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
                    onPressed: () {},
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.brandTeal,
                    child: IconButton(
                      icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                      onPressed: () => setState(() => _paused = !_paused),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: AppColors.textSecondary),
                    onPressed: _goNext,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(label: 'Next →', onPressed: _goNext),
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
