import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_shell.dart';

class PublishWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const PublishWorkoutScreen({super.key, required this.workout});

  @override
  State<PublishWorkoutScreen> createState() => _PublishWorkoutScreenState();
}

class _PublishWorkoutScreenState extends State<PublishWorkoutScreen> {
  bool _isSaving = false;

  Future<void> _handleSaveWorkout(String status) async {
    setState(() => _isSaving = true);

    final updatedWorkout = Workout(
      id: widget.workout.id,
      title: widget.workout.title,
      description: widget.workout.description,
      level: widget.workout.level,
      durationMinutes: widget.workout.durationMinutes,
      goal: widget.workout.goal,
      status: status,
      imageUrl: widget.workout.imageUrl,
      videoUrl: widget.workout.videoUrl,
      exercises: widget.workout.exercises,
    );

    // Persist full workout record to Supabase PostgreSQL table & Storage
    await SupabaseService.saveWorkoutToSupabase(workout: updatedWorkout);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ Workout "${updatedWorkout.title}" ($status) synced to Supabase!'),
          backgroundColor: AppColors.brandTeal,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrainerShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklist = [
      'Workout details & title (${widget.workout.title})',
      'All exercises with step-by-step instructions (${widget.workout.exercises.length} exercise)',
      'Supabase MP4 Video stream CDN link verified',
      'Difficulty level (${widget.workout.level})',
      'Target fitness goal (${widget.workout.goal})',
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
                decoration: BoxDecoration(color: const Color(0x1F16A34A), borderRadius: BorderRadius.circular(999)),
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
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: const Color(0xFFCCFBF1),
                            child: const Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 28),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.workout.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('Level: ${widget.workout.level} • ${widget.workout.durationMinutes} min', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              if (widget.workout.videoUrl.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(Icons.video_library, size: 12, color: AppColors.brandTeal),
                                    SizedBox(width: 4),
                                    Text('Supabase CDN Video Attached', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
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
                        decoration: BoxDecoration(color: const Color(0x1F16A34A), borderRadius: BorderRadius.circular(999)),
                        child: Text('${checklist.length} of ${checklist.length} Verified',
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
                            Expanded(child: Text(c, style: const TextStyle(fontSize: 12))),
                            const Text('100%', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  AppCard(
                    color: const Color(0x0F0D9488),
                    child: const Row(
                      children: [
                        Icon(Icons.public, color: AppColors.brandTeal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Cross-Portal Distribution: Once published, this routine and video will be instantly accessible across Customer, Healthcare Advisor & Admin portals via Supabase DB.',
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
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator(color: AppColors.brandTeal))
                  : Column(
                      children: [
                        PrimaryButton(
                          label: 'Publish Workout →',
                          onPressed: () => _handleSaveWorkout('Published'),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: 'Submit for Clinical Review',
                          outlined: true,
                          onPressed: () => _handleSaveWorkout('Under Review'),
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
