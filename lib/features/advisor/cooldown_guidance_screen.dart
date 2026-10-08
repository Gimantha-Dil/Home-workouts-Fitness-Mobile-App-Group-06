import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_settings_screen.dart';

class _CooldownStep {
  final String title;
  final String desc;
  final String duration;

  const _CooldownStep(this.title, this.desc, this.duration);
}

class CooldownGuidanceScreen extends StatelessWidget {
  const CooldownGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      _CooldownStep('Light Walking', 'Lower core temperature safely', '2-3 min'),
      _CooldownStep('Hamstring Stretch', 'Gentle forward hinge, soft knees', '1 min'),
      _CooldownStep('Quad Stretch', 'Stand tall, stabilize with wall', '1 min'),
      _CooldownStep('Deep Breathing', '4-second inhale, 6-second exhale', '1-2 min'),
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
        title: const Text('Cool-down Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                        child: const Text('• Post-Workout Recovery', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                      ),
                      const Text('Est. 5–7 mins', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Hero Video Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.black87,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.65,
                              child: const AppNetworkImage(
                                url: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop',
                                height: 180,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const Center(
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.brandTeal,
                              child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Guided Session', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                              child: const Text('⏱ 2:32', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Why Cool-down Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.favorite_border, color: AppColors.brandTeal, size: 18),
                            SizedBox(width: 8),
                            Text('Why Cool-down?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A deliberate cool-down helps your heart rate gradually return to baseline, decreases post-exercise muscle soreness, and steadily enhances long-term joint flexibility.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(child: _CoolChip(label: 'Heart Rate', sub: 'Gradual recovery', color: AppColors.info)),
                            SizedBox(width: 6),
                            Expanded(child: _CoolChip(label: 'Flexibility', sub: 'Lengthen fibers', color: AppColors.brandTeal)),
                            SizedBox(width: 6),
                            Expanded(child: _CoolChip(label: 'Soreness', sub: 'Clear lactate', color: AppColors.purple)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Recommended Cool-down', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('0 / 4 completed', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...steps.asMap().entries.map((entry) {
                    final i = entry.key + 1;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFF3F4F6),
                              child: Text('$i', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(step.desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                              child: Text(step.duration, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_box_outline_blank, color: AppColors.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: '← Back to Safety Content',
                    onPressed: () => Navigator.of(context).pop(),
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

class _CoolChip extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;

  const _CoolChip({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}