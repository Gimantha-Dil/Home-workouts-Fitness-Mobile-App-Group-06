import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class EditWorkoutScreen extends StatefulWidget {
  const EditWorkoutScreen({super.key});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  int _tab = 0;

  final _exercises = [
    ('Push Ups (Knee Modified)', '3 sets • 10 reps • 60s rest'),
    ('Bodyweight Squats', '3 sets • 15 reps • 60s rest'),
    ('Walking Lunges', '3 sets • 12 reps • 60s rest'),
    ('Plank Foundation', '3 sets • 30s • 60s rest'),
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
            Text('STEP 3 OF 4 • WORKOUT BUILDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            SizedBox(width: 6),
            _Badge(text: '• Draft', color: AppColors.warning),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Edit Workout Structure', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  const Text('Reorder blocks, adjust working volume, and configure exercise sequence.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  // Workout Header Card
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: Image.network('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Beginner Full Body', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              const Text('Beginner • 12 exercises • 30 min', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Routine Structural Balance', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                  Text('75% Completed', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(value: 0.75, minHeight: 4, backgroundColor: Color(0xFFE5E7EB), valueColor: AlwaysStoppedAnimation(AppColors.brandTeal)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sub Tabs [ Exercises 4 | Details & Settings ]
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tab == 0 ? AppColors.brandTeal : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _tab == 0 ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
                            ),
                            child: Text('Exercises 4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _tab == 0 ? Colors.white : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tab == 1 ? AppColors.brandTeal : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _tab == 1 ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
                            ),
                            child: Text('Details & Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _tab == 1 ? Colors.white : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Exercises List
                  ..._exercises.asMap().entries.map((entry) {
                    final i = entry.key + 1;
                    final (title, sub) = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.drag_indicator, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFCCFBF1),
                              child: Text('0$i', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.tune, size: 16, color: AppColors.brandTeal), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger), onPressed: () {}),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFCCFBF1)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16, color: AppColors.brandTeal),
                    label: const Text('Add Exercise', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(height: 16),
                  // Metabolic Pacing Tip Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                    child: Row(
                      children: const [
                        Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Metabolic Pacing Tip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                              SizedBox(height: 2),
                              Text('Keep resting intervals capped at 60s for beginner routines to stimulate adaptation without cardiac fatigue.',
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Discard', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Save Changes ✓',
                      onPressed: () => Navigator.of(context).pop(),
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
