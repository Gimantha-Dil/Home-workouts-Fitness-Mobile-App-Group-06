import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'admin_shell.dart';

class WorkoutContentManagementScreen extends StatefulWidget {
  const WorkoutContentManagementScreen({super.key});

  @override
  State<WorkoutContentManagementScreen> createState() => _WorkoutContentManagementScreenState();
}

class _WorkoutContentManagementScreenState extends State<WorkoutContentManagementScreen> {
  int _tab = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
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
                  final workoutId = 'w_admin_${DateTime.now().millisecondsSinceEpoch}';
                  try {
                    await FirebaseFirestore.instance.collection('workouts').doc(workoutId).set({
                      'id': workoutId,
                      'title': title,
                      'trainer': trainer.isNotEmpty ? trainer : 'Head Coach',
                      'level': level,
                      'durationMinutes': 25,
                      'status': 'Published',
                      'createdAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    final newWorkout = Workout(
                      id: workoutId,
                      title: title,
                      level: level,
                      durationMinutes: 25,
                      status: 'Published',
                    );
                    await SupabaseService.saveWorkoutToSupabase(workout: newWorkout);

                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _showSnack('Routine "$title" saved to Firebase & public catalog!');
                  } catch (e) {
                    _showSnack('Failed to add routine: $e');
                  }
                }
              },
              child: const Text('Add Routine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditWorkoutDialog(Map<String, dynamic> w) {
    final docId = w['id'] ?? '';
    final titleCtrl = TextEditingController(text: w['title'] ?? '');
    final trainerCtrl = TextEditingController(text: w['trainer'] ?? 'Head Coach');
    final rawStatus = (w['status'] ?? 'Published').toString().toLowerCase();
    String status = 'Published';
    if (rawStatus.contains('pending')) {
      status = 'Pending Review';
    } else if (rawStatus.contains('archive')) {
      status = 'Archived';
    } else {
      status = 'Published';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit "${w['title'] ?? 'Routine'}"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              onPressed: () async {
                if (docId.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('workouts').doc(docId).delete();
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack('Routine removed from catalog.');
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: () async {
                if (docId.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('workouts').doc(docId).update({
                    'title': titleCtrl.text.trim(),
                    'trainer': trainerCtrl.text.trim(),
                    'status': status,
                  });
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack('Routine updated.');
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => AdminShell()),
            );
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
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('workouts').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            var list = docs;
            if (_tab == 1) {
              list = list.where((w) => (w['status'] ?? 'Published') == 'Published').toList();
            } else if (_tab == 2) {
              list = list.where((w) => (w['status'] ?? '') == 'Pending Review').toList();
            }

            if (_searchQuery.isNotEmpty) {
              list = list.where((w) => (w['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) || (w['trainer'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
            }

            final totalCount = docs.length;
            final publishedCount = docs.where((w) => (w['status'] ?? 'Published') == 'Published').length;
            final pendingCount = docs.where((w) => (w['status'] ?? '') == 'Pending Review').length;

            return Column(
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
                          Expanded(child: _tabBtn('All ($totalCount)', 0)),
                          const SizedBox(width: 8),
                          Expanded(child: _tabBtn('Published ($publishedCount)', 1)),
                          const SizedBox(width: 8),
                          Expanded(child: _tabBtn('Pending ($pendingCount)', 2)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('No workout routines found in Firebase Firestore.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: list.length,
                          itemBuilder: (ctx, i) {
                            final w = list[i];
                            final title = w['title'] ?? 'Workout Routine';
                            final trainer = w['trainer'] ?? 'Head Coach';
                            final status = w['status'] ?? 'Published';
                            final level = w['level'] ?? 'Beginner';
                            final isPending = status == 'Pending Review';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: AppColors.brandTeal.withValues(alpha: 0.12),
                                          child: const Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  _Badge(
                                                    text: status,
                                                    color: status == 'Published'
                                                        ? AppColors.success
                                                        : status == 'Pending Review'
                                                            ? AppColors.warning
                                                            : AppColors.textSecondary,
                                                  ),
                                                ],
                                              ),
                                              Text('Trainer: $trainer • Level: $level', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('25 min • 3 Drills', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        Row(
                                          children: [
                                            if (isPending)
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.success,
                                                  minimumSize: const Size(90, 26),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                ),
                                                onPressed: () async {
                                                  final docId = w['id'] ?? '';
                                                  if (docId.isNotEmpty) {
                                                    await FirebaseFirestore.instance.collection('workouts').doc(docId).update({'status': 'Published'});
                                                    _showSnack('Routine "$title" approved & published!');
                                                  }
                                                },
                                                child: const Text('Review & Approve', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                              ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 16, color: AppColors.brandTeal),
                                              onPressed: () => _openEditWorkoutDialog(w),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
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
            );
          },
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
          border: Border.all(color: active ? AppColors.brandTeal : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
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
