import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/circular_timer.dart';
import '../../shared/widgets/common_widgets.dart';
import 'active_workout_screen.dart';

class RestTimerScreen extends StatefulWidget {
  final Workout workout;
  final int nextExerciseIndex;
  final String nextExerciseName;
  final int restSeconds;

  const RestTimerScreen({
    super.key,
    required this.workout,
    required this.nextExerciseIndex,
    required this.nextExerciseName,
    required this.restSeconds,
  });

  @override
  State<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends State<RestTimerScreen> {
  late int _remaining = widget.restSeconds;
  Timer? _timer;
  bool _continued = false;
  bool _paused = false;

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
        _continue();
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

  void _continue() {
    if (!mounted || _continued) return;
    _continued = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(workout: widget.workout, exerciseIndex: widget.nextExerciseIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Active Workout Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                        child: const Text('RECOVERY WINDOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                      ),
                      const Icon(Icons.volume_up_outlined, color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('SET 2 COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  const Text('Active Recovery', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text(
                    'Take a deep belly breath, hydrate, and align your posture for the upcoming glute bridge.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  // Circular Timer
                  CircularTimer(
                    totalSeconds: widget.restSeconds,
                    remainingSeconds: _remaining,
                    label: 'RESTING',
                    color: AppColors.brandTeal,
                  ),
                  const SizedBox(height: 12),
                  // Adjust Rest Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (_remaining >= 10) setState(() => _remaining -= 10);
                        },
                        child: const Text('-10s', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => setState(() => _remaining += 15),
                        child: const Text('+15s', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Breathing Guide Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: const [
                        Icon(Icons.air, color: AppColors.info, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rhythmic Breathing • 4-4-4 Pace', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.info)),
                              SizedBox(height: 2),
                              Text('Inhale 4s • Hold 4s • Exhale 4s', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Up Next Card
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&auto=format&fit=crop',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppColors.brandTeal),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text('UP NEXT (3/6)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                  SizedBox(width: 6),
                                  Text('• Lower Body Focus', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(widget.nextExerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              const Text('3 sets • 12 reps • 45s tempo', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PrimaryButton(label: 'Ready to Continue →', onPressed: _continue),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _paused = !_paused),
                    child: Text(_paused ? 'Resume Rest' : 'Pause Rest', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
