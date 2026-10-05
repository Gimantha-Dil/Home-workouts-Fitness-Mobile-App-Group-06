import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'cooldown_guidance_screen.dart';
import 'exercise_precautions_screen.dart';
import 'health_considerations_screen.dart';
import 'warmup_guidance_screen.dart';
import 'warning_signs_screen.dart';

class SafetyContentScreen extends StatefulWidget {
  const SafetyContentScreen({super.key});

  @override
  State<SafetyContentScreen> createState() => _SafetyContentScreenState();
}

class _SafetyContentScreenState extends State<SafetyContentScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final guides = [
      ('General Safety Tips', 'Important tips for safe home workouts', Icons.verified_user_outlined, AppColors.brandTeal, const ExercisePrecautionsScreen()),
      ('Warm-up Guide', 'Prepare your body before exercise', Icons.wb_sunny_outlined, AppColors.warning, const WarmupGuidanceScreen()),
      ('Cool-down Guide', 'Help your body recover efficiently', Icons.ac_unit_outlined, AppColors.info, const CooldownGuidanceScreen()),
      ('Exercise Precautions', 'Avoid injury and overexertion', Icons.warning_amber_rounded, AppColors.danger, const ExercisePrecautionsScreen()),
      ('Warning Signs', 'When to stop exercising immediately', Icons.rotate_right, AppColors.danger, const WarningSignsScreen()),
      ('Health Considerations', 'Conditions and limitations matrix', Icons.health_and_safety_outlined, AppColors.purple, const HealthConsiderationsScreen()),
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
        title: Row(
          children: const [
            Text('FITPULSE ADVISOR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
            SizedBox(width: 8),
            Text('Safety Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Text('Clinical guidance & exercise protocols', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search safety guides...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Tabs
                  Row(
                    children: [
                      Expanded(child: _tabBtn('All (6)', 0)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Warm-up', 1)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Cool-down', 2)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Precautions', 3)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('SHOWING 6 GUIDES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('• Updated Daily', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...guides.map((g) {
                    final (title, desc, icon, color, screen) = g;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Clinical Reminder Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppColors.brandTeal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Clinical Reminder: Always consult a healthcare provider before starting any new high-intensity training regimen.',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
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
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
