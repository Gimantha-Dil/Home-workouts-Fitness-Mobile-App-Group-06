import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_shell.dart';

class PublishWorkoutScreen extends StatelessWidget {
  final String title;
  final String level;
  final String duration;

  const PublishWorkoutScreen({super.key, required this.title, required this.level, required this.duration});

  @override
  Widget build(BuildContext context) {
    final checklist = const [
      'Workout details',
      'All exercises with instructions',
      'Video uploads',
      'Difficulty level',
      'Target goal',
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
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
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
                              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Level: $level • $duration', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
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
                            Expanded(child: Text(c)),
                            const Text('100%', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  AppCard(
                    color: AppColors.brandTeal.withOpacity(0.06),
                    child: const Row(
                      children: [
                        Icon(Icons.public, color: AppColors.brandTeal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Public Catalog Distribution: once approved and published, this routine will be instantly accessible to all active FitPulse subscribers.',
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
                  PrimaryButton(
                    label: 'Publish Workout',
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const TrainerShell()),
                      (route) => false,
                    ),
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
