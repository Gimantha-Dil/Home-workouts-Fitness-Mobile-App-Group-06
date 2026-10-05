import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class WarningSignsScreen extends StatelessWidget {
  const WarningSignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final warnings = const [
      ('Chest pain or tightness', 'Pressure, squeezing, or radiating pain', Icons.favorite_border),
      ('Shortness of breath', 'Disproportionate or laboured respiration', Icons.air),
      ('Dizziness or fainting', 'Lightheadedness, confusion, or vertigo', Icons.rotate_right),
      ('Severe muscle pain', 'Acute tearing sensation or intense spasms', Icons.bolt),
      ('Joint pain or swelling', 'Sudden localized inflammation or locking', Icons.accessibility_new),
      ('Nausea or vomiting', 'Persistent stomach distress or cold sweats', Icons.sentiment_dissatisfied),
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
        title: const Text('Warning Signs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  // Alert Banner Card (Red)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: const [
                        CircleAvatar(radius: 16, backgroundColor: AppColors.danger, child: Icon(Icons.warning, color: Colors.white, size: 18)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stop Exercising If You Experience', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                              SizedBox(height: 2),
                              Text('If you notice any of the following symptoms, stop immediately and seek medical advice.',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF991B1B), height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...warnings.map((w) {
                    final (title, desc, icon) = w;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 14, backgroundColor: const Color(0xFFFEF2F2), child: Icon(icon, color: AppColors.danger, size: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                  // Notice Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppColors.brandTeal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('When in doubt, stop and consult a healthcare professional.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
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
