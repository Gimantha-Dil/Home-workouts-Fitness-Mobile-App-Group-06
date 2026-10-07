import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class AdminWorkoutProgram {
  final String id;
  String title;
  String trainer;
  String status;
  String level;
  String detail;
  Color statusColor;

  AdminWorkoutProgram({
    required this.id,
    required this.title,
    required this.trainer,
    required this.status,
    required this.level,
    required this.detail,
    required this.statusColor,
  });
}

class WorkoutContentManagementScreen extends StatefulWidget {
  const WorkoutContentManagementScreen({super.key});

  @override
  State<WorkoutContentManagementScreen> createState() => _WorkoutContentManagementScreenState();
}

class _WorkoutContentManagementScreenState extends State<WorkoutContentManagementScreen> {
  int _tab = 0; // 0: All Workouts, 1: Beginner, 2: Intermediate, 3: Advanced

  final List<AdminWorkoutProgram> _workouts = [
    AdminWorkoutProgram(id: '#W001', title: 'Full Body Beginner', trainer: 'Alex Carter', status: 'Published', level: 'BEGINNER', detail: '30 min • 12 exs', statusColor: AppColors.success),
    AdminWorkoutProgram(id: '#W002', title: 'Lower Body Strength', trainer: 'Priya Nimal', status: 'Published', level: 'INTERMEDIATE', detail: '25 min • 10 exs', statusColor: AppColors.success),
    AdminWorkoutProgram(id: '#W003', title: 'Yoga Flow & Mobility', trainer: 'Dulani Fernando', status: 'Published', level: 'BEGINNER', detail: '20 min • 8 exs', statusColor: AppColors.success),
    AdminWorkoutProgram(id: '#W004', title: 'HIIT Cardio Interval', trainer: 'Sajith Perera', status: 'Needs Moderation', level: 'ADVANCED', detail: '45 min • 15 exs • Submitted 2h ago', statusColor: AppColors.warning),
    AdminWorkoutProgram(id: '#W005', title: 'Core & Ab Blast', trainer: 'Nuwan Silva', status: 'Published', level: 'INTERMEDIATE', detail: '15 min • 6 exs', statusColor: AppColors.success),
  ];

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openAddWorkoutDialog() {
    final titleCtrl = TextEditingController();
    final trainerCtrl = TextEditingController(text: 'Gimantha (Super Admin)');
    String level = 'BEGINNER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Workout Program', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Program Title', prefixIcon: Icon(Icons.fitness_center)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: trainerCtrl,
                decoration: const InputDecoration(labelText: 'Trainer / Author', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: level,
                decoration: const InputDecoration(labelText: 'Difficulty Level', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: const ['BEGINNER', 'INTERMEDIATE', 'ADVANCED']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setDialogState(() => level = v!),
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
                final trainer = trainerCtrl.text.trim();
                if (title.isNotEmpty) {
                  final newWorkout = Workout(
                    id: 'w_admin_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    level: level,
                    durationMinutes: 25,
                    status: 'Published',
                  );
                  await SupabaseService.saveWorkoutToSupabase(workout: newWorkout);

                  setState(() {
                    _workouts.insert(
                      0,
                      AdminWorkoutProgram(
                        id: '#W0${_workouts.length + 1}',
                        title: title,
                        trainer: trainer,
                        status: 'Published',
                        level: level,
                        detail: '25 min • 10 exs',
                        statusColor: AppColors.success,
                      ),
                    );
                  });
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    _showSnack('Workout program "$title" published & saved to Supabase!');
                  }
                }
              },
              child: const Text('Publish Program', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditDialog(AdminWorkoutProgram w) {
    final titleCtrl = TextEditingController(text: w.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${w.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'Program Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () {
              final newTitle = titleCtrl.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() => w.title = newTitle);
                Navigator.of(ctx).pop();
                _showSnack('Updated title to "$newTitle"');
              }
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _viewWorkoutDetails(AdminWorkoutProgram w) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Program ID: ${w.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('• Author/Trainer: ${w.trainer}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('• Level: ${w.level}', style: const TextStyle(fontSize: 12, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('• Status: ${w.status}', style: TextStyle(fontSize: 12, color: w.statusColor, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<AdminWorkoutProgram> filtered = _workouts;

    if (_tab == 1) {
      filtered = filtered.where((w) => w.level == 'BEGINNER').toList();
    } else if (_tab == 2) {
      filtered = filtered.where((w) => w.level == 'INTERMEDIATE').toList();
    } else if (_tab == 3) {
      filtered = filtered.where((w) => w.level == 'ADVANCED').toList();
    }

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
        actions: const [
          NotificationIconButton(),
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
                      Text('Workout Content', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _Badge(text: 'Admin Panel', color: AppColors.brandTeal),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Review, moderate, and deploy workout programs across all trainer tiers with certified clinical accuracy.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),

                  // Summary Badges
                  Row(
                    children: [
                      Expanded(child: _SummaryBox(title: 'TOTAL', value: '${_workouts.length}', tag: '+3 this wk', color: AppColors.brandTeal)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'LIVE', value: '${_workouts.where((w) => w.status == 'Published').length}', tag: '93.3% rate', color: AppColors.success)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'FLAGGED', value: '${_workouts.where((w) => w.status == 'Needs Moderation').length}', tag: '!Action req', color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  PrimaryButton(
                    label: '+ Add New Workout Program',
                    onPressed: _openAddWorkoutDialog,
                  ),
                  const SizedBox(height: 14),

                  // Tabs
                  Row(
                    children: [
                      Expanded(child: _tabBtn('All (${_workouts.length})', 0)),
                      const SizedBox(width: 4),
                      Expanded(child: _tabBtn('Beginner', 1)),
                      const SizedBox(width: 4),
                      Expanded(child: _tabBtn('Intermediate', 2)),
                      const SizedBox(width: 4),
                      Expanded(child: _tabBtn('Advanced', 3)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...filtered.map((w) {
                    final isPending = w.status == 'Needs Moderation';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFE0F2FE),
                                  child: Icon(Icons.fitness_center, color: AppColors.info, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          _Badge(text: '• ${w.status}', color: w.statusColor),
                                        ],
                                      ),
                                      Text('Trainer: ${w.trainer} • ${w.id}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _Badge(text: w.level, color: AppColors.brandTeal),
                                    const SizedBox(width: 6),
                                    Text(w.detail, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                  ],
                                ),
                                if (isPending)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandTeal,
                                      minimumSize: const Size(120, 28),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () async {
                                      await SupabaseService.updateWorkoutStatusInSupabase(
                                        workoutId: w.id,
                                        status: 'Published',
                                      );
                                      setState(() {
                                        w.status = 'Published';
                                        w.statusColor = AppColors.success;
                                      });
                                      _showSnack('${w.title} approved and synced to Supabase!');
                                    },
                                    child: const Text('Review & Approve', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () => _viewWorkoutDetails(w)),
                                      IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () => _openEditDialog(w)),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                        onPressed: () {
                                          setState(() => _workouts.removeWhere((item) => item.id == w.id));
                                          _showSnack('${w.title} deleted.');
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
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
        child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
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
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
