import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class WarmupGuidanceScreen extends StatelessWidget {
  const WarmupGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = const [
      ('Arm Circles', 'Rotator cuff & shoulder mobility', '1 minute', 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop'),
      ('Leg Swings', 'Hip flexor and hamstring release', '1 minute', 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop'),
      ('Marching in Place', 'Core elevation & rhythmic activation', '2 minutes', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop'),
      ('Dynamic Stretching', 'Full multi-planar kinetic readiness', '2 minutes', 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&auto=format&fit=crop'),
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
        title: const Text('Warm-Up Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  // Hero Video Card
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                        opacity: 0.65,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.brandTeal,
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                            child: const Text('FULL GUIDED RUN-THROUGH', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                            child: const Text('⏱ 2:45', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Why Warm-up Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.shield_outlined, color: AppColors.brandTeal, size: 18),
                            SizedBox(width: 8),
                            Text('Why Warm-up?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A deliberate warm-up increases core body temperature and blood flow to active skeletal muscles. This primes neural activation, expands joint flexibility, and lowers peak physiological stress—directly mitigating your risk of tendon or ligament injury.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(child: _StatChip(label: 'Blood Flow', value: '+35%', color: AppColors.brandTeal)),
                            SizedBox(width: 6),
                            Expanded(child: _StatChip(label: 'Flexibility', value: '+22%', color: AppColors.info)),
                            SizedBox(width: 6),
                            Expanded(child: _StatChip(label: 'Injury Rate', value: '-54%', color: AppColors.danger)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Recommended Warm-up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('4 Steps • 6 mins total', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...steps.asMap().entries.map((entry) {
                    final i = entry.key + 1;
                    final (title, desc, duration, img) = entry.value;
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
                                color: Colors.grey.shade200,
                                child: Image.network(img, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('$i. $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text('⏱ $duration', style: const TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_outline, color: AppColors.textSecondary, size: 20),
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
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Exercise safely • Listen to your body thresholds', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
