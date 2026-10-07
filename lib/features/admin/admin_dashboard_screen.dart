import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stat_card.dart';
import 'feedback_issues_screen.dart';
import 'management_list_screen.dart';
import 'reports_analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Alex Mercer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('SUPERADMIN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ),
                  ],
                ),
                const Text('System Administrator • Node-01', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                _Badge(text: '• LIVE FEED', color: AppColors.success),
              ],
            ),
            const SizedBox(height: 2),
            const Text('Real-time overview of platform activity', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: const [
                StatCard(label: 'Total Users', value: '1,248', trailing: '+12%', icon: Icons.people_outline, color: AppColors.info),
                StatCard(label: 'Active Trainers', value: '48', trailing: '+5%', icon: Icons.fitness_center, color: AppColors.success),
                StatCard(label: 'Health Advisors', value: '12', trailing: '-0%', icon: Icons.health_and_safety_outlined, color: AppColors.purple),
                StatCard(label: 'Live Workouts', value: '186', trailing: '+8%', icon: Icons.sports_gymnastics_outlined, color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),
            // User Growth Chart Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('User Growth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      _Badge(text: 'H1 2024', color: AppColors.info),
                    ],
                  ),
                  const Text('New verified registrations trajectory', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
                            spots: const [
                              FlSpot(0, 250),
                              FlSpot(1, 400),
                              FlSpot(2, 600),
                              FlSpot(3, 780),
                              FlSpot(4, 950),
                              FlSpot(5, 1100),
                              FlSpot(6, 1248),
                            ],
                            isCurved: true,
                            color: AppColors.brandTeal,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: AppColors.brandTeal.withOpacity(0.08)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // System Alerts Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                          SizedBox(width: 6),
                          Text('System Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                        ],
                      ),
                      _Badge(text: '1 Action Req', color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Trainer Credential Queue • 14m ago', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF78350F))),
                  const SizedBox(height: 2),
                  const Text('3 certified fitness trainers submitted liability certifications & proof of CPR accreditation.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF78350F), height: 1.3)),
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
                          builder: (_) => const ManagementListScreen(
                            title: 'Trainer Management',
                            icon: Icons.fitness_center,
                            color: AppColors.success,
                            showApproveReject: true,
                            items: [
                              ManagementItem(title: 'Alex Carter', subtitle: 'Strength Training', status: 'Approved'),
                              ManagementItem(title: 'Priya Nimal', subtitle: 'Yoga', status: 'Approved'),
                              ManagementItem(title: 'Sajith Perera', subtitle: 'HIIT', status: 'Pending'),
                              ManagementItem(title: 'Nuwan Silva', subtitle: 'Calisthenics', status: 'Rejected'),
                            ],
                          ),
                        )),
                        child: const Text('Review Now', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Dismiss', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
