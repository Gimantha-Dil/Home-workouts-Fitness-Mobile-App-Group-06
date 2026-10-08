import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'goals_achievements_screen.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  int _tab = 0;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progress Range Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Weekly View (7 Days)'),
                  trailing: _tab == 0 ? const Icon(Icons.check, color: AppColors.brandTeal) : null,
                  onTap: () {
                    setState(() => _tab = 0);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  title: const Text('Monthly View (30 Days)'),
                  trailing: _tab == 1 ? const Icon(Icons.check, color: AppColors.brandTeal) : null,
                  onTap: () {
                    setState(() => _tab = 1);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  title: const Text('Quarterly View (3 Months)'),
                  trailing: _tab == 2 ? const Icon(Icons.check, color: AppColors.brandTeal) : null,
                  onTap: () {
                    setState(() => _tab = 2);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KINETIC PULSE LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
            Text('Your Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilterBottomSheet),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: _tabBtn('Week', 0)),
                const SizedBox(width: 8),
                Expanded(child: _tabBtn('Month', 1)),
                const SizedBox(width: 8),
                Expanded(child: _tabBtn('3 Months', 2)),
              ],
            ),
            const SizedBox(height: 16),
            // Bar Chart Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('WORKOUT COMPLETION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(_tab == 0 ? 'Weekly Goal: 5 of 6 Days' : _tab == 1 ? 'Monthly Goal: 22 of 25 Days' : '3-Month Goal: 65 of 75 Days',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                        child: Text(_tab == 0 ? '84% Complete' : _tab == 1 ? '88% Complete' : '87% Complete',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = _tab == 0
                                    ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                    : _tab == 1
                                        ? ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7']
                                        : ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7'];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(days[idx], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        barGroups: _tab == 0
                            ? [
                                _barGroup(0, 70, true),
                                _barGroup(1, 100, true),
                                _barGroup(2, 60, true),
                                _barGroup(3, 85, true),
                                _barGroup(4, 90, true),
                                _barGroup(5, 40, false),
                                _barGroup(6, 10, false),
                              ]
                            : [
                                _barGroup(0, 80, true),
                                _barGroup(1, 95, true),
                                _barGroup(2, 85, true),
                                _barGroup(3, 90, true),
                                _barGroup(4, 75, true),
                                _barGroup(5, 60, true),
                                _barGroup(6, 85, true),
                              ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: const [
                _ProgressTile(title: 'WEIGHT', value: '62 kg', tag: '↓ -2 kg trend', icon: Icons.monitor_weight_outlined, color: AppColors.brandTeal),
                _ProgressTile(title: 'WORKOUTS', value: '12 sessions', tag: '✓ Monthly hit', icon: Icons.fitness_center_outlined, color: AppColors.info),
                _ProgressTile(title: 'CALORIES', value: '1,250 kcal', tag: '↗ +18% vs last week', icon: Icons.local_fire_department_outlined, color: AppColors.warning),
                _ProgressTile(title: 'ACTIVE TIME', value: '6.5 hours', tag: '⏱ Avg 55m / day', icon: Icons.timer_outlined, color: AppColors.purple),
              ],
            ),
            const SizedBox(height: 16),
            // Banner Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F3D3A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.local_fire_department, color: Colors.amber, size: 20)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STREAK MASTER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('5 Days in a Row! You are in the top 5% of active members!', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GoalsAchievementsScreen()),
                    ),
                    child: const Text('View', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, bool active) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB),
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final String title;
  final String value;
  final String tag;
  final IconData icon;
  final Color color;

  const _ProgressTile({required this.title, required this.value, required this.tag, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
