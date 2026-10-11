import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stat_card.dart';
import 'feedback_issues_screen.dart';
import 'user_management_screen.dart';
import 'workout_content_management_screen.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  String _period = '01 Apr 2026 - 30 Apr 2026';
  String _exportFormat = 'CSV Format';
  String _exportScope = 'All Modules';

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _generateCustomReport() async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'type': 'Custom Customer Report',
        'period': _period,
        'totalUsers': 1248,
        'activeUsers': 923,
        'contentViews': 18432,
        'reportedIssues': 6,
        'generatedAt': FieldValue.serverTimestamp(),
      });
      _showSnack('Custom Customer Report generated & saved to Firebase database!');
    } catch (e) {
      _showSnack('Failed to generate report: $e');
    }
  }

  Future<void> _downloadData() async {
    try {
      await FirebaseFirestore.instance.collection('reportDownloads').add({
        'format': _exportFormat,
        'scope': _exportScope,
        'period': _period,
        'downloadedAt': FieldValue.serverTimestamp(),
      });

      _showSnack('Report generated & logged to Firebase database!');
    } catch (e) {
      _showSnack('Download failed: $e');
    }
  }

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
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reports & Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                _Badge(text: '• SYSTEM LIVE', color: AppColors.success),
              ],
            ),
            const SizedBox(height: 2),
            const Text('Comprehensive platform metrics, user growth, and downloadable reports.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),

            // Top Stat Cards
            const Row(
              children: [
                Expanded(child: StatCard(label: 'Total Users', value: '1,248', trailing: '+12%', icon: Icons.people_outline, color: AppColors.brandTeal)),
                SizedBox(width: 10),
                Expanded(child: StatCard(label: 'Active Users', value: '923', trailing: '+15%', icon: Icons.person_add_alt, color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(child: StatCard(label: 'Content Views', value: '18.4K', trailing: '+28%', icon: Icons.visibility_outlined, color: AppColors.info)),
                SizedBox(width: 10),
                Expanded(child: StatCard(label: 'Reported Issues', value: '6', trailing: '-40%', icon: Icons.bug_report_outlined, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 20),

            // USER GROWTH OVER TIME (FlChart LineChart)
            const Text('USER GROWTH & ACTIVE ENGAGEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Active Users (2026)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      _Badge(text: 'Real-time Telemetry', color: AppColors.brandTeal),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                if (val.toInt() >= 0 && val.toInt() < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(months[val.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 400),
                              FlSpot(1, 550),
                              FlSpot(2, 680),
                              FlSpot(3, 820),
                              FlSpot(4, 923),
                              FlSpot(5, 1100),
                            ],
                            isCurved: true,
                            color: AppColors.brandTeal,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.brandTeal.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QUICK NAVIGATION SHORTCUTS
            const Text('MODULE SHORTCUTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                    ),
                    icon: const Icon(Icons.people_outline, size: 16, color: AppColors.brandTeal),
                    label: const Text('Users', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WorkoutContentManagementScreen()),
                    ),
                    icon: const Icon(Icons.fitness_center, size: 16, color: AppColors.info),
                    label: const Text('Workouts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FeedbackIssuesScreen()),
                    ),
                    icon: const Icon(Icons.bug_report_outlined, size: 16, color: AppColors.warning),
                    label: const Text('Issues', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // REPORT GENERATOR & EXPORT SECTION
            const Text('GENERATE & EXPORT SYSTEM REPORTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Custom Report Generator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  const Text('Select parameters to generate custom system analytics.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  const Text('REPORTING PERIOD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _period,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: const [
                      '01 Apr 2026 - 30 Apr 2026',
                      '01 Mar 2026 - 31 Mar 2026',
                      'Q1 2026 (Jan - Mar)',
                      'Full Year 2025',
                    ].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)))).toList(),
                    onChanged: (v) => setState(() => _period = v!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EXPORT FORMAT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _exportFormat,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              items: const ['CSV Format', 'JSON Data', 'PDF Document']
                                  .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 11))))
                                  .toList(),
                              onChanged: (v) => setState(() => _exportFormat = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SCOPE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _exportScope,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              items: const ['All Modules', 'User Management', 'Workouts Only', 'System Issues']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11))))
                                  .toList(),
                              onChanged: (v) => setState(() => _exportScope = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Generate Report',
                          onPressed: _generateCustomReport,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.brandTeal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(120, 44),
                        ),
                        onPressed: _downloadData,
                        icon: const Icon(Icons.download, size: 16, color: AppColors.brandTeal),
                        label: const Text('Export', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                      ),
                    ],
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
