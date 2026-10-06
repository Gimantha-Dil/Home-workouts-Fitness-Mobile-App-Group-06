import 'package:flutter/material.dart';
import '../../core/models/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'workout_details_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final workouts = MockData.workouts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: const [
            Text('Personalized Plan'),
            SizedBox(width: 6),
            CircleAvatar(radius: 3, backgroundColor: AppColors.brandTeal),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _tabBtn('Today', 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _tabBtn('Week', 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _tabBtn('Month', 2)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('WEEK 1 OF 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                              SizedBox(height: 2),
                              Text('Beginner Foundations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('2 of 5 workouts completed', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: const [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: 0.4,
                                strokeWidth: 4,
                                backgroundColor: Color(0xFFCCFBF1),
                                valueColor: AlwaysStoppedAnimation(AppColors.brandTeal),
                              ),
                            ),
                            Text('40%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("TODAY'S QUEUE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('4 Sessions Available', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...workouts.map((w) {
                    final isFirst = w == workouts.first;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: w))),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: Image.network(
                                  w.imageUrl,
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
                                    children: [
                                      Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      if (isFirst) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(10)),
                                          child: const Text('READY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${w.exercises.length} exercises • ${w.level}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 2),
                                      Text('${w.durationMinutes} min', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.warning),
                                      const SizedBox(width: 2),
                                      const Text('140 kcal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isFirst)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandTeal,
                                  minimumSize: const Size(60, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: w))),
                                child: const Text('Start', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              )
                            else
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Hydration Tip Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Remember to stay hydrated Tip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                              SizedBox(height: 2),
                              Text('Take 30-45 sec breathers between reps and stop if you experience joint pinching or dizzy spells.',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF78350F), height: 1.3)),
                            ],
                          ),
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
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }
}
