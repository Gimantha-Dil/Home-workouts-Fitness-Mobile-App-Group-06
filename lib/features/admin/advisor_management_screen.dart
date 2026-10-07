import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class AdvisorManagementScreen extends StatefulWidget {
  const AdvisorManagementScreen({super.key});

  @override
  State<AdvisorManagementScreen> createState() => _AdvisorManagementScreenState();
}

class _AdvisorManagementScreenState extends State<AdvisorManagementScreen> {
  final _advisors = const [
    ('Dr. Silva Fernando', '#H001', 'silva@fitpulse.com', 'Approved', 'Sports Medicine', AppColors.success),
    ('Dr. Nimal Nethmini', '#H002', 'nethmini@fitpulse.com', 'Approved', 'Sports Medicine', AppColors.success),
    ('Dr. Perera Kasun', '#H003', 'perera@fitpulse.com', 'Pending', 'Nutrition', AppColors.warning),
    ('Dr. Wijesiri', '#H004', 'wijesiri@fitpulse.com', 'Approved', 'Physiotherapy', AppColors.success),
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
                      Text('Healthcare Advisors', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _Badge(text: '• 4 Total Live Node', color: AppColors.brandTeal),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Manage health advisors, credentials, and verification statuses.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  // Summary Badges
                  Row(
                    children: const [
                      Expanded(child: _SummaryBox(title: 'APPROVED', value: '3', tag: '75%', color: AppColors.success)),
                      SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'PENDING', value: '1', tag: '1 Action', color: AppColors.warning)),
                      SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'TRACKS', value: '4', tag: 'Active', color: AppColors.info)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._advisors.map((a) {
                    final (name, id, email, status, specialty, statusColor) = a;
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
                                  child: Text(name.split(' ').last[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
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
                                  child: Text('⚕ $specialty', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.info)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPending ? AppColors.brandTeal : Colors.white,
                                    foregroundColor: isPending ? Colors.white : AppColors.brandTeal,
                                    minimumSize: const Size(110, 28),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    side: isPending ? BorderSide.none : const BorderSide(color: AppColors.brandTeal),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {},
                                  child: Text(isPending ? 'Review Credentials' : 'Credentials 📄', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // FitPulse Verification Engine Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: Row(
                      children: const [
                        Icon(Icons.security, color: AppColors.brandTeal, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FitPulse Verification Engine', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                              SizedBox(height: 2),
                              Text('Medical licensing integration v2.4 running daily credential cross-checks.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                            ],
                          ),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
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
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
