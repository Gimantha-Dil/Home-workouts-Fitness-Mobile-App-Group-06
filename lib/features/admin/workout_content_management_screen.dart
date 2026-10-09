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
  int _tab = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<AdminWorkoutProgram> _workouts = [
    AdminWorkoutProgram(id: '#W001', title: 'Beginner Full Body', trainer: 'Coach Alex', status: 'Published', level: 'Beginner', detail: '20 min • 2 Drills', statusColor: AppColors.success),
    AdminWorkoutProgram(id: '#W002', title: 'Cardio Core Blast', trainer: 'Coach Sarah', status: 'Pending Review', level: 'Intermediate', detail: '25 min • 3 Drills', statusColor: AppColors.warning),
    AdminWorkoutProgram(id: '#W003', title: 'Lower Body Strength', trainer: 'Coach Mike', status: 'Published', level: 'Advanced', detail: '30 min • 4 Drills', statusColor: AppColors.success),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openAddWorkoutDialog() {
    final titleCtrl = TextEditingController();
    final trainerCtrl = TextEditingController();
    String level = 'Beginner';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Catalog Routine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Program Title')),
              const SizedBox(height: 8),
              TextField(controller: trainerCtrl, decoration: const InputDecoration(labelText: 'Assigned Trainer')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: level,
                decoration: const InputDecoration(labelText: 'Level', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: const ['Beginner', 'Intermediate', 'Advanced']
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
                        trainer: trainer.isNotEmpty ? trainer : 'Head Coach',
                        status: 'Published',
                        level: level,
                        detail: '25 min • 3 Drills',
                        statusColor: AppColors.success,
                      ),
                    );
                  });
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _showSnack('Routine "$title" added to public catalog!');
                }
              },
              child: const Text('Add Routine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditWorkoutDialog(AdminWorkoutProgram w) {
    final titleCtrl = TextEditingController(text: w.title);
    final trainerCtrl = TextEditingController(text: w.trainer);
    String status = w.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit "${w.title}"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: trainerCtrl, decoration: const InputDecoration(labelText: 'Trainer')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: const ['Published', 'Pending Review', 'Archived']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setDialogState(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _workouts.removeWhere((item) => item.id == w.id));
                Navigator.of(ctx).pop();
                _showSnack('Routine removed from catalog.');
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: () {
                setState(() {
                  w.title = titleCtrl.text.trim();
                  w.trainer = trainerCtrl.text.trim();
                  w.status = status;
                  w.statusColor = status == 'Published'
                      ? AppColors.success
                      : status == 'Pending Review'
                          ? AppColors.warning
                          : AppColors.textSecondary;
                });
                Navigator.of(ctx).pop();
                _showSnack('Routine "${w.title}" updated.');
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
    var list = _workouts;
    if (_tab == 1) {
      list = list.where((w) => w.status == 'Published').toList();
    } else if (_tab == 2) {
      list = list.where((w) => w.status == 'Pending Review').toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((w) => w.title.toLowerCase().contains(_searchQuery.toLowerCase()) || w.trainer.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            _Badge(text: 'ADMIN', color: AppColors.brandTeal),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Workout Program Catalog', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal, minimumSize: const Size(100, 36)),
                        onPressed: _openAddWorkoutDialog,
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: const Text('Add Routine', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search programs or trainers...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _tabBtn('All (${_workouts.length})', 0)),
                      const SizedBox(width: 8),
                      Expanded(child: _tabBtn('Published', 1)),
                      const SizedBox(width: 8),
                      Expanded(child: _tabBtn('Pending', 2)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final w = list[i];
                  final isPending = w.status == 'Pending Review';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: w.statusColor.withValues(alpha: 0.12),
                                child: Icon(Icons.fitness_center, color: w.statusColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: w.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                          child: Text(w.status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: w.statusColor)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Trainer: ${w.trainer} • Level: ${w.level}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    Text(w.detail, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                  ],
                                ),
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
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandTeal),
                                      onPressed: () => _openEditWorkoutDialog(w),
                                    ),
                                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
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
