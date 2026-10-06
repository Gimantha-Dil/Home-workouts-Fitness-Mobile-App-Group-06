import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _masterSwitch = true;
  bool _mornSwitch = true;
  bool _eveSwitch = true;
  bool _weekendSwitch = false;
  bool _inactivitySwitch = true;
  bool _motiSwitch = true;

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16, color: AppColors.brandTeal),
              label: const Text('New', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Workout Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            const Text('Stay consistent with smart scheduling', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            // Master Switch Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCCFBF1))),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: AppColors.brandTeal, child: Icon(Icons.notifications_active, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Enable Reminders • Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandTeal)),
                        SizedBox(height: 2),
                        Text('Smart notifications active • 3 Scheduled', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _masterSwitch,
                    activeColor: AppColors.brandTeal,
                    onChanged: (v) => setState(() => _masterSwitch = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('ACTIVE SCHEDULES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('3 Configured', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            _reminderTile('Morning Workout', 'HIGH INTENSITY', '07:00 AM • Daily • Push & Core', Icons.wb_sunny_outlined, AppColors.warning, _mornSwitch, (v) => setState(() => _mornSwitch = v)),
            const SizedBox(height: 10),
            _reminderTile('Evening Stretch', 'RECOVERY', '06:30 PM • Mon, Wed, Fri', Icons.nightlight_round_outlined, AppColors.info, _eveSwitch, (v) => setState(() => _eveSwitch = v)),
            const SizedBox(height: 10),
            _reminderTile('Weekend Cardio', 'AEROBIC', '09:00 AM • Sat, Sun • Outdoor', Icons.directions_run_outlined, AppColors.brandTeal, _weekendSwitch, (v) => setState(() => _weekendSwitch = v)),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16, color: AppColors.brandTeal),
              label: const Text('Add Custom Reminder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFCCFBF1)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('NOTIFICATION PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _prefTile('Smart Inactivity Nudge', 'Alert gently if inactive for 2 consecutive days', _inactivitySwitch, (v) => setState(() => _inactivitySwitch = v)),
            const SizedBox(height: 10),
            _prefTile('Motivational Boost', 'Inspiring quotes delivered 15 min prior to training', _motiSwitch, (v) => setState(() => _motiSwitch = v)),
          ],
        ),
      ),
    );
  }

  Widget _reminderTile(String title, String badge, String subtitle, IconData icon, Color color, bool value, ValueChanged<bool> onChanged) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.brandTeal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _prefTile(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.brandTeal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
