import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/mock_data.dart';
import '../../core/providers/history_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'profile_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HistoryProvider>().listenToUserHistory(user.uid);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final historyItems = historyProvider.history;
    final fallbackWorkouts = MockData.workouts;

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
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _filterBtn('All', 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _filterBtn('This Week', 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _filterBtn('This Month', 2)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Total Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL TIME', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.info, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('${historyProvider.totalActiveHours.toStringAsFixed(1)}h', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 30, color: const Color(0xFFBAE6FD)),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('SESSIONS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.info, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('${historyProvider.totalSessions} Done', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 30, color: const Color(0xFFBAE6FD)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('BURNED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.warning, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('${historyProvider.totalCaloriesBurned}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.warning)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('April', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (historyItems.isNotEmpty)
                    ...historyItems.map((h) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: const Color(0xFFCCFBF1),
                                  child: const Icon(Icons.fitness_center, color: AppColors.brandTeal),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(h['title'] ?? 'Workout Session', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                                          child: const Text('Completed', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Session Logged', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 2),
                                        Text('${((h['durationSeconds'] as num?) ?? 900) ~/ 60} min', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.fitness_center_outlined, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 2),
                                        Text('${h['exercisesCompleted'] ?? 5} exercises', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.warning),
                                        const SizedBox(width: 2),
                                        Text('${h['caloriesBurned'] ?? 140} kcal', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  else
                    // Demo fallback data when history is empty
                    ...fallbackWorkouts.map((w) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              AppNetworkImage(
                                url: w.imageUrl,
                                width: 50,
                                height: 50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                                          child: const Text('Completed', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text('Apr 24, 2025', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 2),
                                        Text('${w.durationMinutes} min', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.fitness_center_outlined, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 2),
                                        Text('${w.exercises.length} exercises', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.warning),
                                        const SizedBox(width: 2),
                                        const Text('140 kcal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                  // Notice Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium, color: AppColors.brandTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Consistency Streak!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                              SizedBox(height: 2),
                              Text('4 workouts completed in a row this week. You are in the top 5% of active members!', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
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

  Widget _filterBtn(String label, int index) {
    final active = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
