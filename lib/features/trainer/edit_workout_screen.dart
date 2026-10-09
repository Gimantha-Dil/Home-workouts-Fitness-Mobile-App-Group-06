import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/workout_repository.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout? workout;
  const EditWorkoutScreen({super.key, this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final List<(String, String)> _exercises;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout?.title ?? 'Full Body Beginner I');
    _durationController = TextEditingController(text: '${widget.workout?.durationMinutes ?? 15} min');
    _exercises = widget.workout != null && widget.workout!.exercises.isNotEmpty
        ? widget.workout!.exercises.map((e) => (e.name, '${e.sets} sets • ${e.reps} reps')).toList()
        : [
      ('Warm-up Arm Circles', '1 set • 30 seconds'),
      ('Kneeling Push-ups', '3 sets • 10 reps'),
      ('Bodyweight Squats', '3 sets • 12 reps'),
      ('Cool-down Stretch', '1 set • 60 seconds'),
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Exercise Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _exercises.add((name, '3 sets • 10 reps'));
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(int index) {
    final nameController = TextEditingController(text: _exercises[index].$1);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Exercise Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _exercises[index] = (name, _exercises[index].$2);
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    final dur = int.tryParse(_durationController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15;

    final workoutId = (widget.workout != null && widget.workout!.id.isNotEmpty)
        ? widget.workout!.id
        : 'w_${DateTime.now().millisecondsSinceEpoch}';

    final exercisesList = _exercises.map((e) => Exercise(
      id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
      name: e.$1,
      sets: 3,
      reps: 10,
      restSeconds: 30,
    )).toList();

    final updatedWorkout = Workout(
      id: workoutId,
      title: title.isNotEmpty ? title : (widget.workout?.title ?? 'Updated Workout'),
      description: widget.workout?.description ?? 'Custom trainer workout routine.',
      level: widget.workout?.level ?? 'Beginner',
      durationMinutes: dur,
      goal: widget.workout?.goal ?? 'General Fitness',
      status: widget.workout?.status ?? 'Published',
      imageUrl: widget.workout?.imageUrl ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
      videoUrl: widget.workout?.videoUrl,
      exercises: exercisesList,
    );

    final currentUser = context.read<AuthProvider>().currentUser;

    // Save/Update in Supabase PostgreSQL Database 'workouts' table
    await SupabaseService.saveWorkoutToSupabase(workout: updatedWorkout);

    // Also sync to Firestore if user repository is connected
    try {
      if (currentUser != null) {
        final repo = WorkoutRepository();
        await repo.saveWorkout(updatedWorkout, currentUser.id, currentUser.name);
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Workout Title & Duration updated in Supabase!'),
          backgroundColor: AppColors.brandTeal,
        ),
      );
      Navigator.of(context).pop();
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
            Text('WORKOUT BUILDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            SizedBox(width: 6),
            _Badge(text: '• Edit Mode', color: AppColors.brandTeal),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Edit Workout Structure', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  const Text('Reorder blocks, adjust working volume, and configure exercise sequence.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('METADATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _durationController,
                          decoration: const InputDecoration(labelText: 'Target Duration'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('EXERCISE BLOCKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ..._exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final (title, sub) = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.drag_handle, color: AppColors.textSecondary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune, size: 16, color: AppColors.brandTeal),
                              onPressed: () => _showEditExerciseDialog(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                              onPressed: () {
                                setState(() {
                                  _exercises.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(42, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFCCFBF1)),
                    ),
                    onPressed: _showAddExerciseDialog,
                    icon: const Icon(Icons.add, size: 16, color: AppColors.brandTeal),
                    label: const Text('Add Exercise', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save Changes ✓',
                    onPressed: _saveChanges,
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
