import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/models/workout_session.dart';
import '../../core/repositories/history_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stat_card.dart';
import 'customer_shell.dart';
import 'profile_screen.dart';
import 'workout_details_screen.dart';

class WorkoutCompletedScreen extends StatefulWidget {
  final Workout workout;
  final WorkoutSession? session;

  const WorkoutCompletedScreen({
    super.key,
    required this.workout,
    this.session,
  });

  @override
  State<WorkoutCompletedScreen> createState() => _WorkoutCompletedScreenState();
}

class _WorkoutCompletedScreenState extends State<WorkoutCompletedScreen> {
  String _rating = 'Just Right';
  bool _savedHistory = false;

  int computeEstimatedCalories(int activeSeconds) {
    if (activeSeconds <= 0) return 140;
    return ((activeSeconds / 60.0) * 7.5).round();
  }

  @override
  void initState() {
    super.initState();
    _saveHistoryEntry();
  }

  Future<void> _saveHistoryEntry() async {
    if (_savedHistory) return;
    _savedHistory = true;

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final activeSecs = widget.session?.totalActiveDurationSeconds ?? (widget.workout.durationMinutes * 60);
    final calories = computeEstimatedCalories(activeSecs);

    try {
      final repo = HistoryRepository();
      await repo.addHistoryEntry(user.uid, {
        'workoutId': widget.workout.id,
        'title': widget.workout.title,
        'durationSeconds': activeSecs,
        'caloriesBurned': calories,
        'exercisesCompleted': widget.session?.setResults.length ?? widget.workout.exercises.length,
        'rating': _rating,
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final activeSecs = widget.session?.totalActiveDurationSeconds ?? (widget.workout.durationMinutes * 60);
    final minutesDone = (activeSecs / 60.0).round();
    final caloriesDone = computeEstimatedCalories(activeSecs);
    final exercisesDone = widget.session?.setResults.length ?? widget.workout.exercises.length;

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
        title: const Text('Workout Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFCCFBF1),
                    child: Icon(Icons.emoji_events, color: AppColors.brandTeal, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('WORKOUT COMPLETE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Great Job!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('You crushed your session! Keep that athletic momentum going.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: StatCard(label: 'Minutes', value: '$minutesDone', icon: Icons.timer_outlined, color: AppColors.info)),
                const SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Sets Done', value: '$exercisesDone', icon: Icons.fitness_center, color: AppColors.brandTeal)),
                const SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Calories', value: '$caloriesDone', icon: Icons.local_fire_department, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 16),
            // Streak Increased Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFDE68A))),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department, color: AppColors.warning, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Streak Increased to 13 Days! Lv. 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        SizedBox(height: 2),
                        Text('2 days until Level 2 streak badge • Bronze Athlete', style: TextStyle(fontSize: 10, color: Color(0xFF78350F))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Image Card
            AppNetworkImage(
              url: widget.workout.imageUrl,
              height: 140,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 16),
            // Rating Feedback Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('How was this workout?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  const Text('Your response optimizes your next personalized plan', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _ratingOption('Too Easy', Icons.sentiment_satisfied, _rating == 'Too Easy', () => setState(() => _rating = 'Too Easy'))),
                      const SizedBox(width: 8),
                      Expanded(child: _ratingOption('Just Right', Icons.sentiment_very_satisfied, _rating == 'Just Right', () => setState(() => _rating = 'Just Right'))),
                      const SizedBox(width: 8),
                      Expanded(child: _ratingOption('Challenging', Icons.fitness_center, _rating == 'Challenging', () => setState(() => _rating = 'Challenging'))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'View Details →',
              outlined: true,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: widget.workout)),
              ),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Back to Home',
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CustomerShell()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingOption(String label, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFCCFBF1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: active ? AppColors.brandTeal : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? AppColors.brandTeal : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
