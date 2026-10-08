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
    ReminderItem(id: 101, title: 'Morning Workout', badge: 'HIGH INTENSITY', subtitle: '07:00 AM • Daily', icon: Icons.wb_sunny_outlined, color: AppColors.warning, hour: 7, minute: 0),
    ReminderItem(id: 102, title: 'Evening Stretch', badge: 'RECOVERY', subtitle: '06:30 PM • Daily', icon: Icons.nightlight_round_outlined, color: AppColors.info, hour: 18, minute: 30),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedReminders();
  }

  Future<void> _loadSavedReminders() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final savedList = data['reminders'] as List<dynamic>?;
        if (data.containsKey('masterReminders')) {
          _masterSwitch = data['masterReminders'] ?? true;
        }

        if (savedList != null && savedList.isNotEmpty) {
          final loaded = savedList.map((item) {
            final map = Map<String, dynamic>.from(item);
            return ReminderItem(
              id: map['id'] ?? (DateTime.now().millisecondsSinceEpoch % 10000),
              title: map['title'] ?? 'Workout Reminder',
              badge: map['badge'] ?? 'MODERATE',
              subtitle: map['subtitle'] ?? '08:00 AM • Daily',
              icon: Icons.notifications_active_outlined,
              color: AppColors.brandTeal,
              enabled: map['enabled'] ?? true,
              hour: map['hour'] ?? 8,
              minute: map['minute'] ?? 0,
            );
          }).toList();

          setState(() {
            _reminders.clear();
            _reminders.addAll(loaded);
          });
        }
      }
    } catch (_) {}
    await _syncRemindersWithService();
  }

  Future<void> _syncRemindersWithService() async {
    if (!_masterSwitch) {
      await NotificationService().cancelAll();
      return;
    }

    for (final r in _reminders) {
      if (r.enabled) {
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

  void _openAddReminderDialog() async {
    final titleCtrl = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    String intensity = 'MODERATE';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Custom Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Reminder Title (e.g. Core Workout)', prefixIcon: Icon(Icons.fitness_center)),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.brandTeal),
                title: Text('Time: ${selectedTime.format(context)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                trailing: const Text('Change', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: selectedTime);
                  if (picked != null) {
                    setDialogState(() => selectedTime = picked);
                  }
                },
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
                if (title.isNotEmpty) {
                  final formattedTime = selectedTime.format(context);
                  final newId = DateTime.now().millisecondsSinceEpoch % 10000;
                  final newItem = ReminderItem(
                    id: newId,
                    title: title,
                    badge: intensity,
                    subtitle: '$formattedTime • Daily',
                    icon: Icons.notifications_active_outlined,
                    color: AppColors.brandTeal,
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                  );

                  setState(() {
                    _reminders.add(newItem);
                  });

                  await _syncRemindersWithService();
                  await _saveRemindersToFirestore();

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
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

  void _openEditReminderDialog(ReminderItem r) async {
    final titleCtrl = TextEditingController(text: r.title);
    TimeOfDay selectedTime = TimeOfDay(hour: r.hour, minute: r.minute);
    String intensity = r.badge;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit "${r.title}"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.fitness_center)),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.brandTeal),
                title: Text('Time: ${selectedTime.format(context)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                trailing: const Text('Change', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: selectedTime);
                  if (picked != null) {
                    setDialogState(() => selectedTime = picked);
                  }
                },
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
              onPressed: () async {
                // Delete Reminder Action
                setState(() {
                  _reminders.removeWhere((item) => item.id == r.id);
                });
                await _syncRemindersWithService();
                await _saveRemindersToFirestore();

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reminder "${r.title}" deleted.')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: () async {
                final newTitle = titleCtrl.text.trim();
                if (newTitle.isNotEmpty) {
                  final formattedTime = selectedTime.format(context);
                  setState(() {
                    r.title = newTitle;
                    r.badge = intensity;
                    r.hour = selectedTime.hour;
                    r.minute = selectedTime.minute;
                    r.subtitle = '$formattedTime • Daily';
                  });

                  await _syncRemindersWithService();
                  await _saveRemindersToFirestore();

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reminder "$newTitle" updated!')),
                    );
                  }
                }
              },
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    activeThumbColor: AppColors.brandTeal,
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
      onTap: () => _openEditReminderDialog(r),
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandTeal),
            onPressed: () => _openEditReminderDialog(r),
          ),
          Switch(
            value: r.enabled && _masterSwitch,
            activeThumbColor: AppColors.brandTeal,
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
            activeThumbColor: AppColors.brandTeal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
