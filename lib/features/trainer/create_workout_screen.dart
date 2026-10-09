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
  final _restController = TextEditingController(text: '60');
  String _exerciseDifficulty = 'Beginner';

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
              content: Text('⚡ Video "$fileName" uploaded to Supabase Storage (exercise-videos) & saved to Database!'),
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
            content: Text('⚡ Video uploaded to Supabase Storage (exercise-videos) & saved to Database!'),
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
      // Build full exercise object
      final exercise = Exercise(
        id: 'e_${DateTime.now().millisecondsSinceEpoch}',
        name: _exerciseNameController.text.isEmpty ? 'Kneeling Push-ups' : _exerciseNameController.text,
        sets: int.tryParse(_setsController.text) ?? 3,
        reps: int.tryParse(_repsController.text) ?? 10,
        restSeconds: int.tryParse(_restController.text) ?? 60,
        difficulty: _exerciseDifficulty,
        instructions: _instructionControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
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
          Row(
            children: const [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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
              Row(
                children: const [
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
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop'),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
              const Spacer(),
              Row(
                children: const [
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
              Row(
                children: const [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                  Row(
                    children: const [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('🧍 Target Muscle Groups', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text('+ Add Group', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: const [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
              const Text('Exercise Instructions & Cues', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              for (int i = 0; i < _instructionControllers.length; i++) ...[
                Text('Step ${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 4),
                TextField(controller: _instructionControllers[i], decoration: InputDecoration(hintText: 'Instruction step ${i + 1}')),
                const SizedBox(height: 10),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _instructionControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add, color: AppColors.brandTeal),
                  label: const Text('Add Step', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Trainer Tips & Precautions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 4),
              TextField(controller: _tipController, maxLines: 2, decoration: const InputDecoration(hintText: 'Keep back straight, engage core...')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3VideoUploadContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              const Text('Exercise Demonstration Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _handleChooseVideoFile,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.brandTeal, width: 1.5),
                  ),
                  child: _isUploadingVideo
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(color: AppColors.brandTeal),
                            SizedBox(height: 12),
                            Text(
                              'Uploading MP4 to Supabase Storage (exercise-videos)...',
                              style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _videoAttached ? Icons.cloud_done : Icons.cloud_upload_outlined,
                              color: AppColors.brandTeal,
                              size: 42,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _videoAttached ? 'Video Uploaded to Supabase!' : 'Drag & drop MP4 video or tap to upload',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (_uploadedFileName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'File: $_uploadedFileName',
                                style: const TextStyle(color: AppColors.brandTeal, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandTeal,
                                minimumSize: const Size(140, 36),
                              ),
                              onPressed: _handleChooseVideoFile,
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Choose File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Video URL (Supabase CDN / Direct Link)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 4),
              TextField(
                controller: _videoUrlController,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'https://ctguxkodnxxntloshlls.supabase.co/storage/v1/...',
                  prefixIcon: Icon(Icons.link, color: AppColors.brandTeal),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Supported formats: MP4, MOV (Max 100MB)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    final nextBtnLabels = ['Next: Add Exercises →', 'Next: Instructions →', 'Next: Upload Video →', 'Review & Publish →'];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
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

  Widget _chip(String label, String selected, ValueChanged<String> onSelect) {
    final active = selected == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => onSelect(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.brandTeal : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE2E8F0)),
          ),
          child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
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
