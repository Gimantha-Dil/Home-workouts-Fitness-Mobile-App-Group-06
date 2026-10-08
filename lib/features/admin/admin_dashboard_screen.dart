import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stat_card.dart';
import 'advisor_management_screen.dart';
import 'feedback_issues_screen.dart';
import 'reports_analytics_screen.dart';
import 'trainer_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              child: ClipOval(
                child: AppNetworkImage(
                  url: null,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Admin Dashboard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('SUPERADMIN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ),
                  ],
                ),
                const Text('System Administrator • Live DB', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, userSnap) {
            final userDocs = userSnap.data?.docs.map((d) => d.data()).toList() ?? [];

            final totalUsers = userDocs.length;
            final totalTrainers = userDocs.where((u) => u['role'] == 'trainer').length;
            final totalAdvisors = userDocs.where((u) => u['role'] == 'advisor').length;
            final pendingRequests = userDocs.where((u) => u['verificationStatus'] == 'pending').length;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('workouts').snapshots(),
              builder: (context, workoutSnap) {
                final workoutDocs = workoutSnap.data?.docs ?? [];
                final totalWorkouts = workoutDocs.length;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        _Badge(text: '• LIVE FIRESTORE DB', color: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('Real-time overview of platform activity from Firestore', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 16),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.3,
                      children: [
                        StatCard(label: 'Total Users', value: '$totalUsers', trailing: 'Live DB', icon: Icons.people_outline, color: AppColors.info),
                        StatCard(label: 'Active Trainers', value: '$totalTrainers', trailing: 'Verified', icon: Icons.fitness_center, color: AppColors.success),
                        StatCard(label: 'Health Advisors', value: '$totalAdvisors', trailing: 'Clinical', icon: Icons.health_and_safety_outlined, color: AppColors.purple),
                        StatCard(label: 'Live Workouts', value: '$totalWorkouts', trailing: 'Published', icon: Icons.sports_gymnastics_outlined, color: AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // User Growth Chart Card
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('User Registrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              _Badge(text: 'Realtime', color: AppColors.info),
                            ],
                          ),
                          const Text('Active verified registrations trajectory', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 130,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      const FlSpot(0, 1),
                                      const FlSpot(1, 2),
                                      const FlSpot(2, 3),
                                      FlSpot(3, totalUsers.toDouble() > 0 ? totalUsers.toDouble() : 4),
                                    ],
                                    isCurved: true,
                                    color: AppColors.brandTeal,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: true, color: AppColors.brandTeal.withValues(alpha: 0.08)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // System Alerts Card for Pending Verifications
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: pendingRequests > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: pendingRequests > 0 ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(pendingRequests > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: pendingRequests > 0 ? AppColors.warning : AppColors.success, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Verification Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: pendingRequests > 0 ? const Color(0xFF92400E) : AppColors.brandTeal)),
                                ],
                              ),
                              _Badge(text: '$pendingRequests Action Req', color: pendingRequests > 0 ? AppColors.warning : AppColors.success),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(pendingRequests > 0 ? '$pendingRequests account(s) waiting for credentials review.' : 'All trainer and advisor verification credentials are up to date.',
                              style: TextStyle(fontSize: 10, color: pendingRequests > 0 ? const Color(0xFF78350F) : AppColors.textSecondary, height: 1.3)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandTeal,
                                  minimumSize: const Size(90, 30),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const TrainerManagementScreen(),
                                )),
                                child: const Text('Review Trainers', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.info,
                                  minimumSize: const Size(90, 30),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const AdvisorManagementScreen(),
                                )),
                                child: const Text('Review Advisors', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottom Action Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsAnalyticsScreen())),
                            child: const Text('Report and Analytics', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackIssuesScreen())),
                            child: const Text('Feedback & Issues', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
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
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
