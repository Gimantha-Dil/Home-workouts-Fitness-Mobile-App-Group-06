import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_workout_screen.dart';
import 'edit_workout_screen.dart';

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  State<WorkoutManagementScreen> createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> {
  int _tab = 0;

  final _routines = const [
    ('Beginner Full Body', 'v1.4', 'PUBLISHED', 'Beginner • 10 exercises • 30 min', '384 trainees', '↗ +12% this week', AppColors.success),
    ('Lower Body Strength', 'v2.1', 'PUBLISHED', 'Beginner • 10 exercises • 25 min', '512 runs', '★ 4.9 rating', AppColors.success),
    ('Upper Body Toning', 'v1.0', 'PUBLISHED', 'Intermediate • 10 exercises • 35 min', '279 trainees', 'Safety Certified', AppColors.success),
    ('HIIT Cardio', 'v0.9', 'UNDER REVIEW', 'Intermediate • 8 exercises • 25 min', 'Review by Dr. Silva', 'In QA', AppColors.warning),
  ];

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
        title: Row(
          children: const [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            _Badge(text: 'TRAINER', color: AppColors.brandTeal),
          ],
        ),
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
                      const Text('My Workouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandTeal,
                          minimumSize: const Size(90, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateWorkoutScreen())),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Create', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Manage curriculum & live routines', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  // Summary Badges
                  Row(
                    children: const [
                      Expanded(child: _SummaryBox(title: 'ROUTINES', value: '12', tag: '+2 new', color: AppColors.brandTeal)),
                      SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'AVG TIME', value: '28.7m', tag: 'Optimal', color: AppColors.info)),
                      SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'COMPLETION', value: '88.4%', tag: '+4.1%', color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search routines, tags, levels...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Tabs
                  Row(
                    children: [
                      Expanded(child: _tabBtn('All (12)', 0)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Published (9)', 1)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Draft (2)', 2)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Under Review', 3)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._routines.map((r) {
                    final (title, version, status, detail, metric, extra, statusColor) = r;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey.shade200,
                                    child: Image.network('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop', fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          _Badge(text: '• $status', color: statusColor),
                                        ],
                                      ),
                                      Text('$version • $detail', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _Badge(text: metric, color: AppColors.brandTeal),
                                    const SizedBox(width: 6),
                                    Text(extra, style: const TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(60, 28),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditWorkoutScreen())),
                                  icon: const Icon(Icons.edit_outlined, size: 12, color: AppColors.brandTeal),
                                  label: const Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final String tag;
  final Color color;

  const _SummaryBox({required this.title, required this.value, required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
