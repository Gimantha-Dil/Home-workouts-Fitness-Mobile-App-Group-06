import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'active_workout_screen.dart';
import 'exercise_details_screen.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Added to Bookmarks!' : 'Removed from Bookmarks'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareWorkout() {
    Share.share(
      'Check out this "${widget.workout.title}" workout on FitPulse! Level: ${widget.workout.level}, Duration: ${widget.workout.durationMinutes} min.',
      subject: 'FitPulse Workout: ${widget.workout.title}',
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
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.brandTeal : null,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareWorkout,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('COACH VERIFIED PLAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.workout.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                        child: Text('~${widget.workout.durationMinutes * 7} kcal', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.workout.description.isNotEmpty
                        ? widget.workout.description
                        : 'Custom trainer workout routine published to FitPulse catalog.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // Workout Meta Grid
                  Row(
                    children: [
                      Expanded(child: _metaCard('Duration', '${widget.workout.durationMinutes} min', Icons.timer_outlined)),
                      const SizedBox(width: 8),
                      Expanded(child: _metaCard('Movements', '${widget.workout.exercises.length} Drills', Icons.grid_view)),
                      const SizedBox(width: 8),
                      Expanded(child: _metaCard('Equipment', 'Bodyweight', Icons.fitness_center)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Form Cue Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFFD97706), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Form cue: Breathe out during effort, maintain soft knees, and keep a light smile!',
                            style: TextStyle(fontSize: 10, color: Color(0xFF78350F), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${widget.workout.exercises.length} Total • ${widget.workout.level}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...widget.workout.exercises.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final e = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          final exerciseWithVideo = (e.videoUrl != null && e.videoUrl!.isNotEmpty)
                              ? e
                              : Exercise(
                                  id: e.id,
                                  name: e.name,
                                  sets: e.sets,
                                  reps: e.reps,
                                  restSeconds: e.restSeconds,
                                  difficulty: e.difficulty,
                                  instructions: e.instructions,
                                  tip: e.tip,
                                  videoUrl: widget.workout.videoUrl,
                                );
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ExerciseDetailsScreen(exercise: exerciseWithVideo)),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFFCCFBF1),
                              child: Text('$idx', style: const TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      if (e.videoUrl != null && e.videoUrl!.isNotEmpty || (widget.workout.videoUrl != null && widget.workout.videoUrl!.isNotEmpty)) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.play_circle_fill, size: 10, color: AppColors.brandTeal),
                                              SizedBox(width: 2),
                                              Text('VIDEO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${e.sets} sets • ${e.reps} reps • Rest ${e.restSeconds}s', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Doctor Verified Warm-up Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.brandTeal, size: 18),
                            SizedBox(width: 8),
                            Text('Doctor Verified Warm-up Recommended', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Complete 3–5 minutes of light arm circles and high knees before starting to prevent joint strain.',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Read Safety Guidance →', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: 'Start Workout • ${widget.workout.durationMinutes} min',
                onPressed: () {
                  if (!widget.workout.hasExercises) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This workout has no exercises yet.')),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: widget.workout)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaCard(String label, String val, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: AppColors.brandTeal, size: 18),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
