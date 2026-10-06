import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'exercise_details_screen.dart';
import 'safety_guidance_screen.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailsScreen({super.key, required this.workout});

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
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(workout.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                        child: const Text('~140 kcal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    workout.description.isEmpty
                        ? 'A simple full-body workout designed for beginners to build foundational strength, mobility, and healthy habits.'
                        : workout.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  // Info Tags Row
                  Row(
                    children: [
                      _infoTag(Icons.timer_outlined, 'Duration', '${workout.durationMinutes} min'),
                      const SizedBox(width: 8),
                      _infoTag(Icons.grid_view, 'Movements', '${workout.exercises.length} Drills'),
                      const SizedBox(width: 8),
                      _infoTag(Icons.fitness_center_outlined, 'Equipment', 'Bodyweight'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Form Cue Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.tips_and_updates_outlined, color: AppColors.warning, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Form cue: Breathe out during effort, maintain soft knees, and keep a light smile!',
                            style: TextStyle(fontSize: 11, color: Color(0xFF78350F), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${workout.exercises.length} Total • 3 Sets Each', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...workout.exercises.asMap().entries.map((entry) {
                    final i = entry.key + 1;
                    final e = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailsScreen(exercise: e))),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.brandTeal.withOpacity(0.12),
                              child: Text('$i', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      if (i == 2) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(8)),
                                          child: const Text('Key Exercise', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${e.sets} sets • ${e.reps} reps • Rest 30s', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                        Row(
                          children: const [
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
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SafetyGuidanceScreen(workout: workout))),
                          child: const Text('Read Safety Guidance →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
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
                label: 'Start Workout  •  ${workout.durationMinutes} min',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SafetyGuidanceScreen(workout: workout))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.brandTeal),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
