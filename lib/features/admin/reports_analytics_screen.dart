import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
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

      final reportContent = '''
========================================
FITPULSE ADMIN REPORTS & ANALYTICS
========================================
Reporting Period: $_period
Export Scope: $_exportScope
Export Format: $_exportFormat
Generated At: ${DateTime.now().toIso8601String()}

----------------------------------------
KEY PERFORMANCE METRICS
----------------------------------------
- Total Users: 1,248 (+12%)
- Active Users: 923 (+15%)
- Content Views: 18,432 (+28%)
- Reported Issues: 6 (-40%)

----------------------------------------
USER DISTRIBUTION BY ROLE
----------------------------------------
- Customers (General): 78%
- Trainers: 12%
- Healthcare Advisors: 8%
- System Admins: 2%

========================================
End of Official FitPulse Report
========================================
''';

      if (kIsWeb) {
        final bytes = utf8.encode(reportContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final extension = _exportFormat.contains('PDF') ? 'pdf' : _exportFormat.contains('JSON') ? 'json' : 'csv';
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'FitPulse_Report_${DateTime.now().millisecondsSinceEpoch}.$extension')
          ..click();
        html.Url.revokeObjectUrl(url);
      }

      _showSnack('Report downloaded to computer & logged to Firebase database!');
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
            SizedBox(width: 6),
            _Badge(text: 'ADMIN', color: AppColors.brandTeal),
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
                _Badge(text: '• LIVE', color: AppColors.success),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Real-time metrics, platform usage, and role telemetry', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),

            // Select Reporting Period
            const Text('SELECT REPORTING PERIOD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _period,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              items: const ['01 Apr 2026 - 30 Apr 2026', '01 Mar 2026 - 31 Mar 2026', 'Q1 2026 Summary']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) => setState(() => _period = v!),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Generate Custom Report ⚙',
              outlined: true,
              onPressed: _generateCustomReport,
            ),
            const SizedBox(height: 20),

            // Stats Grid (Clickable Cards)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                  child: const StatCard(label: 'TOTAL USERS', value: '1,248', trailing: '↗ +12%', icon: Icons.people_outline, color: AppColors.brandTeal),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                  child: const StatCard(label: 'ACTIVE USERS', value: '923', trailing: '↗ +15%', icon: Icons.bolt, color: AppColors.info),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutContentManagementScreen())),
                  child: const StatCard(label: 'CONTENT VIEWS', value: '18,432', trailing: '↗ +28%', icon: Icons.remove_red_eye_outlined, color: AppColors.purple),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackIssuesScreen())),
                  child: const StatCard(label: 'REPORTED ISSUES', value: '6', trailing: '↘ -40%', icon: Icons.bug_report_outlined, color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Line Chart Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('User Growth Trajectory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Apr 01 - Apr 30', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
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
                              FlSpot(0, 500),
                              FlSpot(1, 620),
                              FlSpot(2, 750),
                              FlSpot(3, 890),
                              FlSpot(4, 1020),
                              FlSpot(5, 1248),
                            ],
                            isCurved: true,
                            color: AppColors.brandTeal,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: AppColors.brandTeal.withValues(alpha: 0.12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Donut Chart Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Text('Categorized by system role', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: [
                          PieChartSectionData(value: 78, color: AppColors.brandTeal, title: '78%', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(value: 12, color: AppColors.info, title: '12%', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(value: 8, color: AppColors.warning, title: '8%', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(value: 2, color: AppColors.danger, title: '2%', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Export Report Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Export Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Instant Export', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FORMAT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _exportFormat,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              items: const ['CSV Format', 'PDF Report', 'JSON Data']
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
                              items: const ['All Modules', 'User Telemetry', 'Workouts Only']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11))))
                                  .toList(),
                              onChanged: (v) => setState(() => _exportScope = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: '⬇ Download Data',
                    onPressed: _downloadData,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}