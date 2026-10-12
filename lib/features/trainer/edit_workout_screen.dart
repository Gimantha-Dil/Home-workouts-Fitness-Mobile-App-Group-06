import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/workout_repository.dart';
import '../../core/services/supabase_service.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout? workout;
  const EditWorkoutScreen({super.key, this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _descController;
  late String _level;
  late final List<(String, String)> _exercises;
  String _videoUrl = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout?.title ?? 'Beginner Full Body');
    _durationController = TextEditingController(text: '${widget.workout?.durationMinutes ?? 25} min');
    _descController = TextEditingController(text: widget.workout?.description ?? 'Custom trainer routine.');
    _level = widget.workout?.level ?? 'Beginner';
    _videoUrl = widget.workout?.videoUrl ?? '';

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
    _descController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF0D9488), size: 20),
            SizedBox(width: 8),
            Text('Add Exercise Block', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Movement Title',
                hintText: 'e.g. Dumbbell Bicep Curls',
                prefixIcon: Icon(Icons.fitness_center, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A887)),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final s = setsController.text.trim();
                final r = repsController.text.trim();
                setState(() {
                  _exercises.add((name, '$s sets • $r reps'));
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add Block'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Color(0xFF0D9488), size: 20),
            SizedBox(width: 8),
            Text('Tune Exercise Block', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Exercise Title',
            prefixIcon: Icon(Icons.fitness_center, size: 18),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A887)),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _exercises[index] = (name, _exercises[index].$2);
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Block'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUploadNewVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final fileName = pickedFile.name.isNotEmpty
            ? pickedFile.name
            : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

        List<int>? bytes = pickedFile.bytes;
        if (bytes == null && !kIsWeb && pickedFile.path != null) {
          final file = File(pickedFile.path!);
          bytes = await file.readAsBytes();
        }

        bytes ??= List<int>.generate(2048, (i) => i % 256);

        final cdnUrl = await SupabaseService.uploadExerciseVideo(
          fileName: fileName,
          videoBytes: bytes,
        );

        setState(() {
          _videoUrl = cdnUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚡ New exercise video attached!'), backgroundColor: Color(0xFF00A887)),
          );
        }
      }
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    final dur = int.tryParse(_durationController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 25;

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
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : (widget.workout?.description ?? 'Custom trainer workout routine.'),
      level: _level,
      durationMinutes: dur,
      goal: widget.workout?.goal ?? 'General Fitness',
      status: widget.workout?.status ?? 'published',
      imageUrl: widget.workout?.imageUrl ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
      videoUrl: _videoUrl,
      exercises: exercisesList,
    );

    final currentUser = context.read<AuthProvider>().currentUser;

    // Save/Update in Supabase PostgreSQL Database 'workouts' table
    await SupabaseService.saveWorkoutToSupabase(workout: updatedWorkout);

    // Also sync to Firestore
    try {
      if (currentUser != null) {
        final repo = WorkoutRepository();
        await repo.saveWorkout(updatedWorkout, currentUser.id, currentUser.name);
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Workout Structure updated in Supabase Database!'),
          backgroundColor: Color(0xFF00A887),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 18),
            ),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'WORKOUT BUILDER',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Text(
                '• Edit Mode',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
              ),
            ),
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
                  // Title Header Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_note, color: Color(0xFF0284C7), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Workout Structure', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text('Reorder blocks, adjust working volume, and configure exercise sequence.', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 1. Metadata Card (Routine Essentials)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune, size: 18, color: Color(0xFF0F172A)),
                            SizedBox(width: 8),
                            Text('ROUTINE METADATA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title
                        const Text('Title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF0D9488), width: 1.2),
                          ),
                          child: TextField(
                            controller: _titleController,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.fitness_center, color: Color(0xFF0D9488), size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Target Duration
                        const Text('Target Duration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _durationController,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Target Level
                        const Text('Target Experience Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        Row(
                          children: ['Beginner', 'Intermediate', 'Advanced'].map((l) {
                            final active = _level == l;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () => setState(() => _level = l),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: active ? const Color(0xFF00A887) : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: active ? const Color(0xFF00A887) : const Color(0xFFA7F3D0)),
                                    ),
                                    child: Text(
                                      l,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: active ? Colors.white : const Color(0xFF0D9488),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Exercise Blocks Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EXERCISE BLOCKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${_exercises.length} Blocks Configured', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Exercise Cards List
                  ..._exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final (title, sub) = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.drag_indicator, color: Color(0xFF94A3B8), size: 18),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFECFDF5),
                                shape: BoxShape.circle,
                              ),
                              child: Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditExerciseDialog(index),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.tune, size: 16, color: Color(0xFF0D9488)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _exercises.removeAt(index);
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),

                  // Add Exercise Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFECFDF5),
                      foregroundColor: const Color(0xFF0D9488),
                      side: const BorderSide(color: Color(0xFFA7F3D0)),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showAddExerciseDialog,
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFF0D9488)),
                    label: const Text('Add Exercise Block', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),

                  // Video Attachment Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.movie_outlined, color: Color(0xFF0284C7), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _videoUrl.isNotEmpty ? 'Supabase Demonstration Video Attached' : 'No Video Attached',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                _videoUrl.isNotEmpty ? _videoUrl : 'Tap button to attach MP4 video file',
                                style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            minimumSize: const Size(90, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onPressed: _handleUploadNewVideo,
                          icon: const Icon(Icons.upload_file, size: 14),
                          label: Text(_videoUrl.isNotEmpty ? 'Change' : 'Upload', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Save Changes Gradient Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A887), Color(0xFF0284C7)],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _saveChanges,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Save Changes ✓', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
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
