import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_settings_screen.dart';

class HealthConsiderationsScreen extends StatefulWidget {
  const HealthConsiderationsScreen({super.key});

  @override
  State<HealthConsiderationsScreen> createState() => _HealthConsiderationsScreenState();
}

class _HealthConsiderationsScreenState extends State<HealthConsiderationsScreen> {
  final Set<String> _selectedConditions = {};

  final _conditions = const [
    ('Heart Conditions', 'Cardiovascular assessment', 'People with heart conditions should consult a doctor before starting.', Icons.favorite_border),
    ('Diabetes', 'Metabolic & glycemic control', 'Monitor blood sugar levels during exercise.', Icons.water_drop_outlined),
    ('Joint Problems', 'Mobility & cartilage care', 'Use low-impact exercises and avoid high-impact movements.', Icons.accessibility_new),
    ('Pregnancy', 'Trimester-specific protocols', 'Follow safe workout guidelines and get medical advice.', Icons.child_care),
    ('Chronic Illnesses', 'Systemic endurance limits', 'Manage your condition and exercise within safe limits.', Icons.health_and_safety_outlined),
    ('Previous Injuries', 'Rehab & load balancing', 'Be cautious and follow rehabilitation guidelines.', Icons.healing),
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
        title: const Text('Health Consideration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  // Baseline Wellness Criteria Card
                  const AppCard(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Baseline Wellness Criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Review each category carefully to customize pace, exertion thresholds, and equipment selection.',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._conditions.map((c) {
                    final (title, category, desc, icon) = c;
                    final isChecked = _selectedConditions.contains(title);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              _selectedConditions.remove(title);
                            } else {
                              _selectedConditions.add(title);
                            }
                          });
                        },
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 14, backgroundColor: isChecked ? AppColors.brandTeal.withValues(alpha: 0.12) : const Color(0xFFF3F4F6), child: Icon(icon, color: isChecked ? AppColors.brandTeal : AppColors.textSecondary, size: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isChecked ? AppColors.brandTeal : AppColors.textPrimary)),
                                    Text(category, style: const TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: isChecked,
                                activeColor: AppColors.brandTeal,
                                onChanged: (v) {
                                  setState(() {
                                    if (v!) {
                                      _selectedConditions.add(title);
                                    } else {
                                      _selectedConditions.remove(title);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_selectedConditions.length} conditions acknowledged', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => setState(() => _selectedConditions.clear()),
                        child: const Text('Reset all', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Clinical Notice Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.brandTeal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CLINICAL NOTICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                              SizedBox(height: 2),
                              Text('Always consult your healthcare provider for personalized advice.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
              child: PrimaryButton(
                label: 'Confirm & Proceed →',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
