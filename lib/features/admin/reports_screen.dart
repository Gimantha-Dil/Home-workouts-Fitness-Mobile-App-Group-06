import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _feedback = [
    ('F001', 'Nethmi Silva', 'Great app! Really helpful', 'Resolved'),
    ('I002', 'Kasun Perera', 'Video not loading', 'Open'),
    ('F003', 'Sanduni Fernando', 'Very helpful content', 'Resolved'),
    ('I004', 'Tharindu Wijesinghe', 'Incorrect workout data', 'In Progress'),
  ];

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final buf = StringBuffer();
      buf.writeln('ID,User,Description,Status');
      for (final f in _feedback) {
        buf.writeln('"${f.$1}","${f.$2}","${f.$3}","${f.$4}"');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fitpulse_feedback_report.csv');
      await file.writeAsString(buf.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'FitPulse Platform Analytics & Feedback Report',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export report: $e')),
        );
      }
    }
  }

  void _showGenerateReportDialog(BuildContext context) {
    String type = 'User Engagement';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Custom Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Report Type:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: const ['User Engagement', 'Trainer Accreditation', 'Physio Safety Logs', 'System Error Reports']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (val) {
                if (val != null) type = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () {
              Navigator.of(ctx).pop();
              _exportCsv(context);
            },
            child: const Text('Generate & Export'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          TextButton(
            onPressed: () => _exportCsv(context),
            child: const Text('Export', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showGenerateReportDialog(context),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Generate Custom Report'),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: const [
                StatCard(label: 'Total Users', value: '1,248', icon: Icons.people_outline, trailing: '+12%', color: AppColors.info),
                StatCard(label: 'Active Users', value: '923', icon: Icons.bolt_outlined, trailing: '+10%', color: AppColors.success),
                StatCard(label: 'Content Views', value: '18,432', icon: Icons.visibility_outlined, trailing: '+15%', color: AppColors.purple),
                StatCard(label: 'Reported Issues', value: '6', icon: Icons.report_gmailerrorred_outlined, color: AppColors.danger),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Growth', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
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
                            spots: const [FlSpot(0, 1000), FlSpot(1, 1080), FlSpot(2, 1150), FlSpot(3, 1200), FlSpot(4, 1248)],
                            isCurved: true,
                            color: AppColors.adminPrimary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: AppColors.adminPrimary.withValues(alpha: 0.08)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Feedback & Issues', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ..._feedback.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${f.$1} • ${f.$2}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          Text(f.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusBadge(status: f.$4),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
