import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class ReminderItem {
  int id;
  String title;
  String badge;
  String subtitle;
  IconData icon;
  Color color;
  bool enabled;
  int hour;
  int minute;

  ReminderItem({
    required this.id,
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.enabled = true,
    this.hour = 8,
    this.minute = 0,
  });
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _masterSwitch = true;
  bool _inactivitySwitch = true;
  bool _motiSwitch = true;

  final List<ReminderItem> _reminders = [
    ReminderItem(id: 101, title: 'Morning Workout', badge: 'HIGH INTENSITY', subtitle: '07:00 AM • Daily • Push & Core', icon: Icons.wb_sunny_outlined, color: AppColors.warning, hour: 7, minute: 0),
    ReminderItem(id: 102, title: 'Evening Stretch', badge: 'RECOVERY', subtitle: '06:30 PM • Mon, Wed, Fri', icon: Icons.nightlight_round_outlined, color: AppColors.info, hour: 18, minute: 30),
    ReminderItem(id: 103, title: 'Weekend Cardio', badge: 'AEROBIC', subtitle: '09:00 AM • Sat, Sun • Outdoor', icon: Icons.directions_run_outlined, color: AppColors.brandTeal, enabled: false, hour: 9, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _syncRemindersWithService();
  }

  Future<void> _syncRemindersWithService() async {
    if (!_masterSwitch) {
      await NotificationService().cancelAll();
      return;
    }

    for (final r in _reminders) {
      if (r.enabled) {
        // Schedule daily or weekly repeating notification
        for (int day = 1; day <= 7; day++) {
          await NotificationService().scheduleWeeklyReminder(
            id: r.id * 10 + day,
            title: 'FitPulse: ${r.title}',
            body: 'Time for your scheduled workout! Stay consistent.',
            dayOfWeek: day,
            hour: r.hour,
            minute: r.minute,
          );
        }
      } else {
        for (int day = 1; day <= 7; day++) {
          await NotificationService().cancel(r.id * 10 + day);
        }
      }
    }
  }

  Future<void> _saveRemindersToFirestore() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final list = _reminders
          .map((r) => {
                'id': r.id,
                'title': r.title,
                'badge': r.badge,
                'subtitle': r.subtitle,
                'enabled': r.enabled,
                'hour': r.hour,
                'minute': r.minute,
              })
          .toList();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'reminders': list,
        'masterReminders': _masterSwitch,
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('master_reminders', _masterSwitch);
    } catch (_) {}
  }

  void _openAddReminderDialog() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '08:00 AM');
    String intensity = 'MODERATE';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Custom Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Reminder Title (e.g. Core Workout)', prefixIcon: Icon(Icons.fitness_center)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(labelText: 'Time (e.g. 08:00 AM)', prefixIcon: Icon(Icons.access_time)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: intensity,
                decoration: const InputDecoration(labelText: 'Intensity', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: const ['HIGH INTENSITY', 'MODERATE', 'RECOVERY', 'AEROBIC']
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: (v) => setDialogState(() => intensity = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final timeStr = timeCtrl.text.trim();
                if (title.isNotEmpty) {
                  final newId = DateTime.now().millisecondsSinceEpoch % 10000;
                  final newItem = ReminderItem(
                    id: newId,
                    title: title,
                    badge: intensity,
                    subtitle: '$timeStr • Daily',
                    icon: Icons.notifications_active_outlined,
                    color: AppColors.brandTeal,
                    hour: 8,
                    minute: 0,
                  );

                  setState(() {
                    _reminders.add(newItem);
                  });

                  await _syncRemindersWithService();
                  await _saveRemindersToFirestore();

                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reminder "$title" added successfully!')),
                    );
                  }
                }
              },
              child: const Text('Save Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _openAddReminderDialog,
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
                      children: [
                        Text(_masterSwitch ? 'Enable Reminders • Active' : 'Reminders Muted', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandTeal)),
                        const SizedBox(height: 2),
                        Text(_masterSwitch ? 'Smart notifications active • ${_reminders.where((r) => r.enabled).length} Scheduled' : 'All alerts paused', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _masterSwitch,
                    activeColor: AppColors.brandTeal,
                    onChanged: (v) async {
                      setState(() => _masterSwitch = v);
                      await _syncRemindersWithService();
                      await _saveRemindersToFirestore();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ACTIVE SCHEDULES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('${_reminders.length} Configured', style: const TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ..._reminders.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _reminderTile(r, (v) async {
                    setState(() => r.enabled = v);
                    await _syncRemindersWithService();
                    await _saveRemindersToFirestore();
                  }),
                )),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: _openAddReminderDialog,
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

  Widget _reminderTile(ReminderItem r, ValueChanged<bool> onChanged) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: r.color.withValues(alpha: 0.12), child: Icon(r.icon, color: r.color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: r.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(r.badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: r.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(r.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: r.enabled && _masterSwitch,
            activeColor: AppColors.brandTeal,
            onChanged: _masterSwitch ? onChanged : null,
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
