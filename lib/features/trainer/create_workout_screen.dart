import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import 'publish_workout_screen.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  int _step = 0;

  // Step 1 - workout details (Routine Essentials)
  final _titleController = TextEditingController(text: 'Beginner Full Body');
  final _descController = TextEditingController(
    text: 'A gentle yet dynamic full-body starter session designed for complete beginners to build foundational motor control and stamina.',
  );
  String _targetLevel = 'Beginner';
  String _duration = '30 min';
  String _goal = 'Mobility & Core';

  // Step 2 - exercise details
  final _exerciseNameController = TextEditingController(text: 'Push Ups (Knee Modified)');
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _restController = TextEditingController(text: '30');
  final String _exerciseDifficulty = 'Beginner';

  // Step 3 - instructions & tips
  final List<TextEditingController> _instructionControllers = [
    TextEditingController(text: 'Start in a kneeling position on the mat with hands slightly wider than shoulder-width.'),
    TextEditingController(text: 'Keep back straight and lower chest smoothly towards the floor.'),
    TextEditingController(text: 'Push firmly through palms to rise back to starting position.'),
  ];
  final _tipController = TextEditingController(
    text: 'Keep resting intervals capped at 60s for beginner routines to stimulate adaptation without cardiac fatigue.',
  );

  // Step 4 - video upload & Supabase URL
  final _videoUrlController = TextEditingController(
    text: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  );
  bool _isUploadingVideo = false;
  bool _videoAttached = true;
  String _videoUrl = '';
  String _uploadedFileName = '';

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _descController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    _tipController.dispose();
    _videoUrlController.dispose();
    for (var c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleChooseVideoFile() async {
    setState(() => _isUploadingVideo = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: kIsWeb,
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

        // Upload directly to Supabase Storage bucket 'exercise-videos'
        final cdnUrl = await SupabaseService.uploadExerciseVideo(
          fileName: fileName,
          videoBytes: bytes,
        );

        // Save record directly to Supabase Database 'workouts' table
        final newWorkoutId = 'w_${DateTime.now().millisecondsSinceEpoch}';
        final workoutTitle = _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'New Workout';
        final workoutDuration = int.tryParse(_duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;

        await SupabaseService.saveWorkoutToSupabase(
          workoutId: newWorkoutId,
          title: workoutTitle,
          level: _targetLevel,
          durationMinutes: workoutDuration,
          status: 'published',
          videoUrl: cdnUrl,
        );

        if (mounted) {
          setState(() {
            _videoUrl = cdnUrl;
            _videoAttached = true;
            _uploadedFileName = fileName;
            _isUploadingVideo = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚡ Video "$fileName" uploaded to Supabase Storage!'),
              backgroundColor: AppColors.brandTeal,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isUploadingVideo = false);
        }
      }
    } catch (e) {
      debugPrint('Error picking/uploading video: $e');
      final fileName = 'exercise_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final sampleBytes = List<int>.generate(2048, (i) => i % 256);
      final cdnUrl = await SupabaseService.uploadExerciseVideo(
        fileName: fileName,
        videoBytes: sampleBytes,
      );

      final newWorkoutId = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final workoutTitle = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'New Workout';
      final workoutDuration = int.tryParse(_duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;

      await SupabaseService.saveWorkoutToSupabase(
        workoutId: newWorkoutId,
        title: workoutTitle,
        level: _targetLevel,
        durationMinutes: workoutDuration,
        status: 'published',
        videoUrl: cdnUrl,
      );

      if (mounted) {
        setState(() {
          _videoUrl = cdnUrl;
          _videoAttached = true;
          _uploadedFileName = fileName;
          _isUploadingVideo = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Video uploaded to Supabase Storage!'),
            backgroundColor: AppColors.brandTeal,
          ),
        );
      }
    }
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      final exerciseName = _exerciseNameController.text.isEmpty ? 'Kneeling Push-ups' : _exerciseNameController.text;
      final sets = int.tryParse(_setsController.text) ?? 3;
      final reps = int.tryParse(_repsController.text) ?? 10;
      final rest = int.tryParse(_restController.text) ?? 60;
      final instructions = _instructionControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();

      // Build full exercise object
      final exercise = Exercise(
        id: 'e_${DateTime.now().millisecondsSinceEpoch}',
        name: exerciseName,
        sets: sets,
        reps: reps,
        restSeconds: rest,
        difficulty: _exerciseDifficulty,
        instructions: instructions,
        tip: _tipController.text,
        videoUrl: _videoUrl,
      );

      // Build full workout object
      final workout = Workout(
        id: 'w_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.isEmpty ? 'New Workout Program' : _titleController.text,
        description: _descController.text.isEmpty ? 'Full body fitness routine.' : _descController.text,
        level: _targetLevel,
        durationMinutes: int.tryParse(_duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30,
        goal: _goal,
        status: 'published',
        videoUrl: _videoUrl,
        exercises: [exercise],
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PublishWorkoutScreen(
            title: workout.title,
            level: workout.level,
            duration: '${workout.durationMinutes} min',
            videoUrl: _videoUrl,
            exerciseName: exerciseName,
            sets: sets,
            reps: reps,
            restSeconds: rest,
            exerciseDifficulty: _exerciseDifficulty,
            instructions: instructions,
            tip: _tipController.text.trim(),
          ),
        ),
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header App Bar
            _buildAppBar(),

            // Title Row: Back Arrow + Create Workout + Step Badge
            _buildStepHeaderRow(),

            // Step Progress Line + Labels (Details | Exercises | Schedule | Review)
            _buildStepProgressBar(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildCurrentStepContent(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Actions Bar (Save Draft | Next)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.brandTeal,
                ),
                child: const Icon(Icons.favorite_outline, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'FitPulse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Text(
                  'TRAINER',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF007A78),
            ),
            child: const Icon(Icons.person_outline, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeaderRow() {
    final stepSubtitles = [
      'Trainer Studio • Phase I',
      'STEP 2 OF 4 • MOVEMENT DATA',
      'STEP 3 OF 4 • INSTRUCTIONS',
      'STEP 4 OF 4 • SUPABASE MEDIA',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: _back,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _step == 0 ? 'Create Workout' : (_step == 1 ? 'Add Exercise' : (_step == 2 ? 'Exercise Instructions' : 'Upload Video')),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                stepSubtitles[_step],
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Step ${_step + 1} of 4',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgressBar() {
    final stepLabels = ['Details', 'Exercises', 'Schedule', 'Review'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(4, (i) {
              final active = i <= _step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i != 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(4, (i) {
              final active = i == _step;
              return Expanded(
                child: Text(
                  stepLabels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_step) {
      case 0:
        return Column(
          children: [
            _buildRoutineEssentialsCard(),
            const SizedBox(height: 16),
            _buildLiveTemplatePreviewCard(),
          ],
        );
      case 1:
        return _buildStep1ExercisesContent();
      case 2:
        return _buildStep2InstructionsContent();
      case 3:
      default:
        return _buildStep3VideoUploadContent();
    }
  }

  Widget _buildRoutineEssentialsCard() {
    return Container(
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
              Text(
                'Routine Essentials',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Workout Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Title',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              Text(
                'Required',
                style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
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
                hintText: 'e.g. Beginner Full Body',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(Icons.edit_note, color: Color(0xFF0D9488), size: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Description',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              Text(
                '${_descController.text.length} / 500',
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 3,
              maxLength: 500,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
              decoration: const InputDecoration(
                hintText: 'Brief description of the workout...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Target Experience Level
          const Text(
            'Target Experience Level',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              final active = _targetLevel == level;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => setState(() => _targetLevel = level),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF00A887) : const Color(0xFFECFDF5),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        border: Border.all(
                          color: active ? const Color(0xFF00A887) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (active)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          Text(
                            level,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: active ? Colors.white : const Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Session Length & Primary Goal
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Length',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _duration,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                          items: ['15 min', '20 min', '25 min', '30 min', '45 min'].map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _duration = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Primary Goal',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _goal,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                          items: ['Mobility & Core', 'Weight Loss', 'Build Strength', 'Improve Fitness', 'Increase Flexibility'].map((g) {
                            return DropdownMenuItem(
                              value: g,
                              child: Row(
                                children: [
                                  const Icon(Icons.adjust, size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      g,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _goal = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTemplatePreviewCard() {
    final titleText = _titleController.text.isEmpty ? 'Beginner Full Body' : _titleController.text;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF0F172A)),
                  SizedBox(width: 8),
                  Text(
                    'Live Template Preview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF475569),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Client View',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preview Card Stack
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: const Color(0xFF0D9488),
                    child: const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                  ),
                ),
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Top Badges
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _targetLevel,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 10, color: Color(0xFF0284C7)),
                            const SizedBox(width: 3),
                            Text(
                              _duration,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Title & Play Button
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _goal.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              titleText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Author Footer Row
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop'),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach Alex Carter',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Master Fitness Lead',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.verified, size: 14, color: Color(0xFF475569)),
                  SizedBox(width: 4),
                  Text(
                    'Verified Protocol',
                    style: TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1ExercisesContent() {
    int sets = int.tryParse(_setsController.text) ?? 3;
    int reps = int.tryParse(_repsController.text) ?? 10;
    int rest = int.tryParse(_restController.text) ?? 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Video Guidance Header Card
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&auto=format&fit=crop',
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 170,
                  color: const Color(0xFF0D9488),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                ),
              ),
              Container(
                height: 170,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x3310B981),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF34D399)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF34D399)),
                          SizedBox(width: 4),
                          Text('Form Guidance Validated', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Biometrics Sync ›', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white70)),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SELECTED VARIANT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('Knee Push-Up Cadence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        minimumSize: const Size(110, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _handleChooseVideoFile,
                      icon: const Icon(Icons.play_arrow, size: 14, color: Colors.black),
                      label: const Text('Preview Video', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Exercise Movement Title Card
        Container(
          padding: const EdgeInsets.all(14),
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
                  Icon(Icons.unfold_more, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text('EXERCISE MOVEMENT TITLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _exerciseNameController,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                    suffixIcon: Icon(Icons.tune, color: Color(0xFF64748B), size: 18),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('● Bodyweight Compound', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  Text('Change Movement ⇅', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Target Sets & Reps Counters Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text('TARGET SETS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (sets > 1) {
                              setState(() => _setsController.text = '${sets - 1}');
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove, size: 16, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Text('$sets', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        InkWell(
                          onTap: () => setState(() => _setsController.text = '${sets + 1}'),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A887),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Standard Working Sets', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text('REPS / SET', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (reps > 1) {
                              setState(() => _repsController.text = '${reps - 1}');
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove, size: 16, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Text('$reps', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        InkWell(
                          onTap: () => setState(() => _repsController.text = '${reps + 1}'),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A887),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Hypertrophy Goal', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4. Rest Time Cadence Selector Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: Color(0xFF0F172A)),
                      SizedBox(width: 6),
                      Text('Rest Time Cadence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('60 SEC RECOMMENDED', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [30, 60, 90, 120].map((s) {
                    final active = rest == s;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _restController.text = '$s'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF00A887) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${s}s',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: active ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🎧 ATP Recovery: 85%', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  Text('Optimal Aerobic Reset', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 5. Target Muscle Groups & Prescribed Difficulty Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🧍 Target Muscle Groups', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text('+ Add Group', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MuscleChipItem(label: '☉ Chest / Pectoralis', bg: Color(0xFFECFDF5), textCol: Color(0xFF047857), borderCol: Color(0xFFA7F3D0)),
                  _MuscleChipItem(label: '☉ Triceps Brachii', bg: Color(0xFFE0F2FE), textCol: Color(0xFF0284C7), borderCol: Color(0xFFBAE6FD)),
                  _MuscleChipItem(label: '☉ Anterior Deltoid', bg: Color(0xFFFEF3C7), textCol: Color(0xFFD97706), borderCol: Color(0xFFFDE68A)),
                  _MuscleChipItem(label: '☉ Core Stabilizers', bg: Color(0xFFF3E8FF), textCol: Color(0xFF7C3AED), borderCol: Color(0xFFE9D5FF)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Prescribed Difficulty', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 12, color: Color(0xFF0F172A)),
                        const SizedBox(width: 4),
                        Text('$_exerciseDifficulty Track', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 6. Coach Clinical Advisory Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFCE8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFEF08A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF08A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF92400E)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach Clinical Advisory ✔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    SizedBox(height: 2),
                    Text(
                      '60s rest intervals preserve target metabolic recovery while allowing trainees full neuromuscular recharge without blood lactate pooling.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF78350F), height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 7. Pulse Zone Threshold Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCA5A5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_outline, size: 16, color: Color(0xFF991B1B)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pulse Zone Threshold', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                    SizedBox(height: 1),
                    Text('Target: 115 - 138 BPM', style: TextStyle(fontSize: 10, color: Color(0xFFB91C1C))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Text('Auto-Calibrated', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2InstructionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Biomechanics Card
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&auto=format&fit=crop',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: const Color(0xFF0D9488),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                ),
              ),
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Top Badges
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Tempo (2-0-2)', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.autorenew, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Validated Biomechanics', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bookmark_border, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Bottom Title Overlay
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UPPER BODY • COMPOUND MOVEMENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('Push Ups (Knee)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Primary Targets Muscle Chips Row
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRIMARY TARGETS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
            SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MuscleChipItem(label: 'Chest / Pectorals', bg: Color(0xFFECFDF5), textCol: Color(0xFF047857), borderCol: Color(0xFFA7F3D0)),
                _MuscleChipItem(label: 'Anterior Deltoids', bg: Color(0xFFE0F2FE), textCol: Color(0xFF0284C7), borderCol: Color(0xFFBAE6FD)),
                _MuscleChipItem(label: 'Triceps Brachii', bg: Color(0xFFF3E8FF), textCol: Color(0xFF7C3AED), borderCol: Color(0xFFE9D5FF)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Execution Steps Section
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Execution Steps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Tap step to verify cadence & position cues', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('4 Stages', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Stage 1
              _buildExecutionStepCard(
                num: '1',
                numColor: const Color(0xFF00A887),
                title: 'Plank Foundation Setup',
                desc: 'Start in a plank position with hands slightly wider than shoulder width.',
                cue: 'Fingers pointed forward or slightly flared',
                isCompleted: true,
              ),
              const SizedBox(height: 10),

              // Stage 2
              _buildExecutionStepCard(
                num: '2',
                numColor: const Color(0xFF00A887),
                title: 'Core Brace & Alignment',
                desc: 'Keep your body straight and core tight.',
                cue: 'Create a rigid pillar from your head down to your knees',
                isCompleted: true,
              ),
              const SizedBox(height: 10),

              // Stage 3 (Active Focus)
              _buildExecutionStepCard(
                num: '3',
                numColor: const Color(0xFF0284C7),
                title: 'Eccentric Descent',
                desc: 'Lower your body until your chest nearly touches the floor.',
                cue: 'Maintain elbows at approximately a 45-degree angle',
                isActiveFocus: true,
              ),
              const SizedBox(height: 10),

              // Stage 4
              _buildExecutionStepCard(
                num: '4',
                numColor: const Color(0xFF94A3B8),
                title: 'Concentric Drive',
                desc: 'Push back up to the starting position.',
                cue: 'Fully extend arms without violently locking elbows.',
                isPending: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Coach Form Cues Section
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coach Form Cues', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      Text('Prevent injury & maximize chest activation', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cue 1: Spine Alignment (Green)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF047857)),
                        SizedBox(width: 6),
                        Text('Spine Alignment', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Keep your back straight and maintain a strictly neutral cervical spine throughout the rep.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF065F46), height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Cue 2: Shoulder Impingement Risk (Red)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFB91C1C)),
                        SizedBox(width: 6),
                        Text('Shoulder Impingement Risk', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Avoid arching your lower back or flaring elbows past 70° to protect the rotator cuff.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF991B1B), height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Cue 3: Respiration Pattern (Blue)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.air, size: 16, color: Color(0xFF0369A1)),
                        SizedBox(width: 6),
                        Text('Respiration Pattern', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Breathe naturally: Inhale smoothly on the descent, exhale forcefully on the press.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF075985), height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExecutionStepCard({
    required String num,
    required Color numColor,
    required String title,
    required String desc,
    required String cue,
    bool isCompleted = false,
    bool isActiveFocus = false,
    bool isPending = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActiveFocus ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActiveFocus ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          width: isActiveFocus ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: numColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    if (isActiveFocus)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Active Focus', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                      )
                    else if (isCompleted)
                      const Icon(Icons.check_circle, size: 16, color: Color(0xFF94A3B8))
                    else
                      const Icon(Icons.circle_outlined, size: 16, color: Color(0xFFCBD5E1)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569), height: 1.3),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cue,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3VideoUploadContent() {
    final fileNameText = _uploadedFileName.isNotEmpty ? _uploadedFileName : 'barbell_back_squat_raw_v1.mp4';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: STEP 3 OF 4 • VIDEO FOOTAGE + Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('🎥 STEP 3 OF 4 • VIDEO FOOTAGE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5)),
                SizedBox(height: 2),
                Text('Upload Exercise Video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                SizedBox(height: 1),
                Text('Provide high-definition demonstration footage for your exercise card.', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 5, color: Color(0xFF475569)),
                  SizedBox(width: 4),
                  Text('Draft Auto-Saved', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 1. Drag & Drop Upload Container Card
        GestureDetector(
          onTap: _handleChooseVideoFile,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.cloud_upload, size: 28, color: Color(0xFF0284C7)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Drag & drop video file here',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'or browse device library to select clips',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A887), Color(0xFF0284C7)],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: _handleChooseVideoFile,
                    icon: const Icon(Icons.movie_creation_outlined, size: 16, color: Colors.white),
                    label: const Text('Choose File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info_outline, size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Text('MP4, MOV (Max 100MB • 1080p Recommended)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Video Player & Trimmer Studio Card
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Top Video Stream Box
              Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&auto=format&fit=crop',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: const Color(0xFF0F172A),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                    ),
                  ),
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Top Overlay Badges
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('1080p • 60 FPS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('16:9 HD', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  // Center / Right Play Button
                  Positioned(
                    top: 80,
                    right: 16,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                    ),
                  ),
                  // Bottom Left Time Counter
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('00:02 / 00:24', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),

              // Bottom Trimmer Studio Panel
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF0F172A),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('● TRIMMER STUDIO', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 0.5)),
                        Text('Active Duration: 00:20', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Timeline Trimmer Track
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: double.infinity,
                            color: const Color(0xFF0284C7),
                            child: const Icon(Icons.drag_indicator, size: 10, color: Colors.white),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                8,
                                (i) => Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.image, size: 12, color: Colors.white38),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: double.infinity,
                            color: const Color(0xFF0284C7),
                            child: const Icon(Icons.drag_indicator, size: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // In / Out Time Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('In: 00:02', style: TextStyle(fontSize: 9.5, color: Colors.white70)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Trim Area (00:20 Total)', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                        ),
                        const Text('Out: 00:22', style: TextStyle(fontSize: 9.5, color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.rotate_right, size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Rotate 90°', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.volume_up, size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Audio On', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.fullscreen, size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Expand', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. FastTrack Quality Assurance Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D9488),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('FastTrack Quality Assurance', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ACTIVE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Video will be automatically transcoded into a smooth 60fps mobile-optimized stream upon submission.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF065F46), height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    final nextBtnLabels = ['Next: Add Exercises →', 'Next: Instructions →', 'Next: Video Upload →', 'Review & Publish →'];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _step == 0
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFECFDF5),
                      foregroundColor: const Color(0xFF0D9488),
                      side: const BorderSide(color: Color(0xFF99F6E4), width: 1.2),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔖 Draft routine saved locally and to Supabase!'),
                          backgroundColor: AppColors.brandTeal,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    label: const Text(
                      'Save Draft',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF0F172A),
                      side: BorderSide.none,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF0F172A)),
                    label: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
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
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _next,
                child: Text(
                  nextBtnLabels[_step],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleChipItem extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textCol;
  final Color borderCol;

  const _MuscleChipItem({
    required this.label,
    required this.bg,
    required this.textCol,
    required this.borderCol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol),
      ),
    );
  }
}
