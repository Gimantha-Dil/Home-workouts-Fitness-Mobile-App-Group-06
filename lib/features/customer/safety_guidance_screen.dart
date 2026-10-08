import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'active_workout_screen.dart';
import 'profile_screen.dart';

class SafetyGuidanceScreen extends StatelessWidget {
  final Workout workout;
  const SafetyGuidanceScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final tips = const [
      ('PREPARATION', 'Warm up for 5–10 minutes', 'Gradually elevate heart rate and joint temperature prior to dynamic load.', Icons.timer_outlined, AppColors.warning),
      ('MOVEMENT QUALITY', 'Use proper form over load', 'Focus on alignment, controlled tempo, and avoiding pushing yourself past technical failure.', Icons.warning_amber_rounded, AppColors.danger),
      ('PHYSIOLOGY', 'Stay consistently hydrated', 'Sip water throughout your workout sets to regulate cellular fluid levels and muscle contraction.', Icons.water_drop_outlined, Color(0xFF2563EB)),
      ('CRUCIAL ALERT', 'Stop immediately if unwell', 'Halt exercise right away if you experience sharp joint pain, dizziness, or unusual shortness of breath.', Icons.favorite_border, AppColors.danger),
      ('MEDICAL CLEARANCE', 'Consult your practitioner', 'Seek advice from a certified healthcare professional if you manage chronic injuries or medical diagnoses.', Icons.health_and_safety_outlined, Color(0xFF16A34A)),
    ];

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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('CLINICAL SAFETY STANDARD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Your Well-being Comes First', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text(
                    'Before you start, please review these key movement rules to train safely, optimize performance, and stay injury-free.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  // Doctor & Physio Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: AppColors.brandTeal, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Doctor & Physiotherapist App', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('Certified sports physiology protocol', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...tips.map((t) {
                    final (category, title, desc, icon, color) = t;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: color.withValues(alpha: 0.12),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFFD1D5DB)),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Target Session Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: Row(
                      children: const [
                        Icon(Icons.bolt, color: AppColors.brandTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Session', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              Text('45 min Functional Hypertrophy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text('Moderate • RPE 7', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: "Got it, Let's Workout! →",
                onPressed: () {
                  if (!workout.hasExercises) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This workout has no exercises yet.')),
                    );
                    return;
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: workout)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
