import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class TrainerManagementScreen extends StatefulWidget {
  const TrainerManagementScreen({super.key});

  @override
  State<TrainerManagementScreen> createState() => _TrainerManagementScreenState();
}

class _TrainerManagementScreenState extends State<TrainerManagementScreen> {
  String _statusFilter = 'All Status';

  final _trainers = const [
    ('Alex Carter', '#T001', 'alex@fitpulse.com', 'Approved', 'Strength Training', AppColors.success),
    ('Priya Nimal', '#T002', 'priya@fitpulse.com', 'Approved', 'Yoga & Mobility', AppColors.success),
    ('Sajith Perera', '#T003', 'sajith@fitpulse.com', 'Pending', 'HIIT & Endurance • Docs 2h ago', AppColors.warning),
    ('Dulani Fernando', '#T004', 'dulani@fitpulse.com', 'Approved', 'Cardio Fitness', AppColors.success),
    ('Nuwan Silva', '#T005', 'nuwan@fitpulse.com', 'Rejected', 'Calisthenics', AppColors.danger),
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
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, size: 20), onPressed: () {}),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Trainer Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _Badge(text: '• 12 Active', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Review qualifications, pending approvals, and active coaches.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  // Summary Cards
                  Row(
                    children: const [
                      Expanded(child: _SummaryBox(title: 'TOTAL', value: '15', tag: 'Coaches', color: AppColors.brandTeal)),
                      SizedBox(width: 6),
                      Expanded(child: _SummaryBox(title: 'APPROVED', value: '12', tag: '80%', color: AppColors.success)),
                      SizedBox(width: 6),
                      Expanded(child: _SummaryBox(title: 'PENDING', value: '2', tag: 'Review', color: AppColors.warning)),
                      SizedBox(width: 6),
                      Expanded(child: _SummaryBox(title: 'REJECTED', value: '1', tag: 'Closed', color: AppColors.danger)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: '+ Add Trainer',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search name, email, or ID...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          initialValue: _statusFilter,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          items: const ['All Status', 'Approved', 'Pending', 'Rejected']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 10))))
                              .toList(),
                          onChanged: (v) => setState(() => _statusFilter = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._trainers.map((t) {
                    final (name, id, email, status, specialty, statusColor) = t;
                    final isPending = status == 'Pending';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.brandTeal.withOpacity(0.12),
                                  child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          _Badge(text: '• $status', color: statusColor),
                                        ],
                                      ),
                                      Text('$id • $email', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
                                  child: Text('⚡ $specialty', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.info)),
                                ),
                                if (isPending)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandTeal,
                                      minimumSize: const Size(100, 28),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {},
                                    child: const Text('Review Profile', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}),
                                      IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () {}),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Clinical Standards Verified Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('All approved trainers have completed CPR accreditation and automated biometric coaching verification.',
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
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final String tag;
  final Color color;

  const _SummaryBox({required this.title, required this.value, required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text(tag, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
        ],
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
