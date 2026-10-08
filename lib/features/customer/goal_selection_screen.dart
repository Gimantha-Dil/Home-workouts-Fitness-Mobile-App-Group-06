import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'customer_shell.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final Set<String> _selectedGoals = {'Weight Loss', 'Improve Fitness'};

  final _goals = const [
    ('Weight Loss', 'Popular', 'Burn fat & optimize metabolic rate', Icons.monitor_weight_outlined),
    ('Build Strength', '', 'Hypertrophy, tone & core power', Icons.fitness_center_outlined),
    ('Improve Fitness', '', 'Cardiovascular endurance & VO2 max', Icons.favorite_border),
    ('Stay Healthy', '', 'Daily movement, vitality & longevity', Icons.favorite_outline),
    ('Increase Flexibility', '', 'Joint mobility, posture & stretch flow', Icons.self_improvement),
  ];

  Future<void> _saveGoalsAndFinish() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'goals': _selectedGoals.toList(),
          'profileCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          await context.read<AuthProvider>().refreshUserFromFirestore(user);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Text('STEP 2 OF 3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                SizedBox(width: 4),
                Text('Profile Setup', style: TextStyle(fontSize: 10, color: AppColors.brandTeal)),
                SizedBox(width: 4),
                Icon(Icons.check_circle, size: 12, color: AppColors.brandTeal),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personalized Routine • Clinical Grade', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.info, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              const Text('What is your main goal?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('You can choose more than one. We\'ll tailor your weekly intensity, calories, and recovery zones.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
              const SizedBox(height: 20),
              ..._goals.map((g) {
                final (title, badge, desc, icon) = g;
                final isSelected = _selectedGoals.contains(title);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGoals.remove(title);
                        } else {
                          _selectedGoals.add(title);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? AppColors.brandTeal : const Color(0xFFE5E7EB), width: isSelected ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected ? AppColors.brandTeal.withValues(alpha: 0.12) : const Color(0xFFF3F4F6),
                            child: Icon(icon, color: isSelected ? AppColors.brandTeal : AppColors.textSecondary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? AppColors.brandTeal : AppColors.textPrimary)),
                                    if (badge.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(10)),
                                        child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 20, color: isSelected ? AppColors.brandTeal : AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Smart Heart-Rate Calibrated Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Smart Heart-Rate Calibrated', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          SizedBox(height: 2),
                          Text('Each selected goal fine-tunes your aerobic training zones according to ACSM cardio benchmarks.',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continue →',
                onPressed: () async {
                  await _saveGoalsAndFinish();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const CustomerShell()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
