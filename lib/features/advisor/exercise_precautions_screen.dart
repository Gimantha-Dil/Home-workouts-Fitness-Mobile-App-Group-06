import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_settings_screen.dart';

class ExercisePrecautionsScreen extends StatelessWidget {
  const ExercisePrecautionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final principles = const [
      ('01', 'Listen to your body', 'If you feel pain, dizziness, or unusual fatigue, stop immediately.', Icons.hearing_outlined, AppColors.danger),
      ('02', 'Avoid overexertion', 'Start slow and increase intensity gradually.', Icons.speed, AppColors.warning),
      ('03', 'Stay hydrated', 'Drink water before, during and after exercise.', Icons.water_drop_outlined, AppColors.info),
      ('04', 'Use proper form', 'Correct technique helps prevent injury.', Icons.accessibility_new, AppColors.brandTeal),
      ('05', 'Wear suitable clothing', 'Choose comfortable and breathable workout clothes and shoes.', Icons.checkroom, AppColors.purple),
      ('06', 'Consult a professional', 'If you have a medical condition, injury or are unsure, seek advice from a healthcare professional.', Icons.medical_services_outlined, Color(0xFF16A34A)),
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
        title: const Text('Exercise Precautions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdvisorSettingsScreen()),
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
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: const [
                        Icon(Icons.shield_outlined, color: AppColors.brandTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Safety Guidelines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('7 principles to prevent injury', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        _Badge(text: 'UPDATED', color: AppColors.brandTeal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 100,
                      color: Colors.black45,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned.fill(
                            child: AppNetworkImage(
                              url: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop',
                              height: 100,
                              width: double.infinity,
                            ),
                          ),
                          Container(color: Colors.black38),
                          const Text('FOUNDATION • FORM • LONGEVITY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...principles.map((p) {
                    final (num, title, desc, icon, color) = p;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: color.withValues(alpha: 0.12),
                              child: Icon(icon, color: color, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                                ],
                              ),
                            ),
                            Text(num, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: '✓ I understand & accept',
                onPressed: () => Navigator.of(context).pop(),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
