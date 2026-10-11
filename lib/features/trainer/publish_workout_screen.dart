import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/workout_repository.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_shell.dart';

class PublishWorkoutScreen extends StatefulWidget {
  final String title;
  final String level;
  final String duration;
  final String videoUrl;
  final String exerciseName;
  final int sets;
  final int reps;
  final int restSeconds;
  final String exerciseDifficulty;
  final List<String> instructions;
  final String tip;

  const PublishWorkoutScreen({
    super.key,
    required this.title,
    required this.level,
    required this.duration,
    this.videoUrl = '',
    this.exerciseName = 'Main Exercise',
    this.sets = 3,
    this.reps = 10,
    this.restSeconds = 30,
    this.exerciseDifficulty = 'Beginner',
    this.instructions = const [],
    this.tip = '',
  });

  @override
  State<PublishWorkoutScreen> createState() => _PublishWorkoutScreenState();
}

class _PublishWorkoutScreenState extends State<PublishWorkoutScreen> {
  bool _publishing = false;

  Future<void> _publishWorkout(BuildContext context) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (user.verificationStatus != 'approved') {
      messenger.showSnackBar(
        const SnackBar(content: Text('Account Pending Admin Approval: You cannot publish workouts until the admin verifies your credentials.')),
      );
      setState(() => _publishing = false);
      return;
    }

    setState(() => _publishing = true);

    try {
      final repo = WorkoutRepository();
      final newWorkoutId = 'w_${DateTime.now().millisecondsSinceEpoch}';

      final workout = Workout(
        id: newWorkoutId,
        title: widget.title,
        description: 'Custom trainer workout routine published to FitPulse catalog.',
        level: widget.level,
        durationMinutes: int.tryParse(widget.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20,
        status: 'published',
        videoUrl: widget.videoUrl,
        exercises: [
          Exercise(
            id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
            name: widget.exerciseName.isNotEmpty ? widget.exerciseName : 'Primary Exercise',
            sets: widget.sets,
            reps: widget.reps,
            restSeconds: widget.restSeconds,
            difficulty: widget.exerciseDifficulty,
            instructions: widget.instructions.where((i) => i.trim().isNotEmpty).toList(),
            tip: widget.tip,
            videoUrl: widget.videoUrl,
          ),
        ],
      );

      // Save to Firestore via Repository
      await repo.saveWorkout(workout, user.id, user.name);

      // Save/Sync to Supabase PostgreSQL Database 'workouts' table
      await SupabaseService.saveWorkoutToSupabase(
        workoutId: newWorkoutId,
        title: workout.title,
        level: workout.level,
        durationMinutes: workout.durationMinutes,
        status: 'published',
        videoUrl: widget.videoUrl,
      );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('⚡ Workout & Video published successfully to Supabase & Firestore!'),
            backgroundColor: AppColors.brandTeal,
          ),
        );
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TrainerShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _publishing = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to publish workout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklist = [
      'Workout Title: ${widget.title}',
      'Primary Exercise: ${widget.exerciseName}',
      'Volume: ${widget.sets} sets x ${widget.reps} reps',
      'Difficulty Level: ${widget.level}',
      'Video Upload: ${widget.videoUrl.isNotEmpty ? "Attached" : "Optional"}',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publish Workout'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                child: const Text('Ready to Launch', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        const SizedBox(width: 56, height: 56, child: EmptyOrPlaceholderImage(icon: Icons.fitness_center, height: 56)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Level: ${widget.level} • ${widget.duration}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('Exercise: ${widget.exerciseName}', style: const TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Text('Publishing Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                        child: Text('${checklist.length} Verified',
                            style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...checklist.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  AppCard(
                    color: AppColors.brandTeal.withValues(alpha: 0.06),
                    child: const Row(
                      children: [
                        Icon(Icons.public, color: AppColors.brandTeal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Public Catalog Distribution: once published, this routine and video will be instantly accessible to all active FitPulse subscribers.',
                              style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  if (_publishing)
                    const CircularProgressIndicator()
                  else
                    PrimaryButton(
                      label: 'Publish Workout',
                      onPressed: () => _publishWorkout(context),
                    ),
                  const SizedBox(height: 10),
                  PrimaryButton(label: 'Save Draft', outlined: true, onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
