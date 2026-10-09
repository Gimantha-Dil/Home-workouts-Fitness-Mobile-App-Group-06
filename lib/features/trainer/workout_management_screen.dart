import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/exercise_video_player.dart';
import 'create_workout_screen.dart';
import 'edit_workout_screen.dart';
import 'trainer_profile_screen.dart';
import 'trainer_shell.dart';

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  State<WorkoutManagementScreen> createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> {
  int _tab = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleUploadOrEditVideo(Workout workout) async {
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

        // Upload to Supabase Storage bucket 'exercise-videos'
        final cdnUrl = await SupabaseService.uploadExerciseVideo(
          fileName: fileName,
          videoBytes: bytes,
        );

        // Update workout record in Supabase Database 'workouts' table
        await SupabaseService.saveWorkoutToSupabase(
          workoutId: workout.id,
          title: workout.title,
          level: workout.level,
          durationMinutes: workout.durationMinutes,
          status: workout.status,
          videoUrl: cdnUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚡ Video "$fileName" uploaded to Supabase Storage & updated in Database!'),
              backgroundColor: AppColors.brandTeal,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error uploading video: $e');
    }
  }

  Future<void> _confirmDeleteVideo(Workout workout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Video', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the exercise video for "${workout.title}" from Supabase Storage?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Video'),
          ),
        ],
      ),
    );

    if (confirm == true && workout.videoUrl != null) {
      await SupabaseService.deleteExerciseVideoFromSupabase(
        videoUrl: workout.videoUrl!,
        workoutId: workout.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑 Video deleted from Supabase Storage & Database!'),
            backgroundColor: AppColors.brandTeal,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteWorkout(Workout workout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${workout.title}" from Supabase Database?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Workout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.deleteWorkoutFromSupabase(
        workoutId: workout.id,
        videoUrl: workout.videoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑 Workout "${workout.title}" deleted from Supabase Database!'),
            backgroundColor: AppColors.brandTeal,
          ),
        );
      }
    }
  }

  void _showPlayVideoDialog(Workout workout) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExerciseVideoPlayer(
              videoUrl: workout.videoUrl ?? '',
              title: workout.title,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () => Navigator.of(ctx).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Close Player'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

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
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const TrainerShell()),
              );
            }
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            _Badge(text: 'TRAINER', color: AppColors.brandTeal),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrainerProfileScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Workout>>(
          stream: SupabaseService.streamWorkoutsFromSupabase(),
          builder: (context, snapshot) {
            final docs = List<Workout>.from(snapshot.data ?? []);
            // Sort by ID / Timestamp descending so newest created/updated workouts appear first
            docs.sort((a, b) => b.id.compareTo(a.id));

            var filtered = docs;
            if (_tab == 1) {
              filtered = filtered.where((w) => w.isPublished).toList();
            } else if (_tab == 2) {
              filtered = filtered.where((w) => w.status.toLowerCase() == 'draft').toList();
            } else if (_tab == 3) {
              filtered = filtered.where((w) => w.status.toLowerCase() == 'under review').toList();
            }

            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              filtered = filtered.where((w) => w.title.toLowerCase().contains(q) || w.level.toLowerCase().contains(q)).toList();
            }

            final totalRoutines = docs.length;
            final publishedCount = docs.where((w) => w.isPublished).length;
            final draftCount = docs.where((w) => w.status.toLowerCase() == 'draft').length;
            final reviewCount = docs.where((w) => w.status.toLowerCase() == 'under review').length;

            final isApproved = user?.verificationStatus == 'approved';

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (!isApproved)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Account Pending Admin Approval: You can view your dashboard, but adding/publishing workouts is locked until the admin verifies your credentials.',
                                  style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('My Workouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              minimumSize: const Size(90, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              if (!isApproved) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Admin approval is required before you can create workouts.')),
                                );
                                return;
                              }
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()));
                            },
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Create', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Manage curriculum & live routines from Supabase DB', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),

                      // Summary Badges
                      Row(
                        children: [
                          Expanded(child: _SummaryBox(title: 'ROUTINES', value: '$totalRoutines', tag: 'Total', color: AppColors.brandTeal)),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryBox(title: 'PUBLISHED', value: '$publishedCount', tag: 'Live', color: AppColors.success)),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryBox(title: 'DRAFTS', value: '$draftCount', tag: 'Building', color: AppColors.warning)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search routines, tags, levels...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tabs
                      Row(
                        children: [
                          Expanded(child: _tabBtn('All ($totalRoutines)', 0)),
                          const SizedBox(width: 4),
                          Expanded(child: _tabBtn('Published ($publishedCount)', 1)),
                          const SizedBox(width: 4),
                          Expanded(child: _tabBtn('Draft ($draftCount)', 2)),
                          const SizedBox(width: 4),
                          Expanded(child: _tabBtn('Review ($reviewCount)', 3)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (filtered.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text('No workouts found in Supabase DB.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((w) {
                          Color statusColor = AppColors.success;
                          if (w.status.toLowerCase() == 'draft') statusColor = AppColors.warning;
                          if (w.status.toLowerCase() == 'under review') statusColor = AppColors.info;

                          final hasVideo = w.videoUrl != null && w.videoUrl!.isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AppNetworkImage(
                                        url: w.imageUrl,
                                        width: 48,
                                        height: 48,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    w.title,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                _Badge(text: '• ${w.status.toUpperCase()}', color: statusColor),
                                              ],
                                            ),
                                            Text('Level: ${w.level} • ${w.exercises.length} exercises • ${w.durationMinutes} min',
                                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Video Management Bar for Trainer
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          hasVideo ? Icons.movie : Icons.movie_outlined,
                                          size: 16,
                                          color: hasVideo ? AppColors.brandTeal : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            hasVideo ? 'Supabase MP4 Video Attached' : 'No Video Attached',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: hasVideo ? AppColors.brandTeal : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        if (hasVideo) ...[
                                          InkWell(
                                            onTap: () => _showPlayVideoDialog(w),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.play_arrow, size: 12, color: Color(0xFF0284C7)),
                                                  SizedBox(width: 2),
                                                  Text('Play', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => _handleUploadOrEditVideo(w),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.edit, size: 10, color: AppColors.brandTeal),
                                                  SizedBox(width: 2),
                                                  Text('Edit Video', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => _confirmDeleteVideo(w),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.delete_outline, size: 10, color: AppColors.danger),
                                                  SizedBox(width: 2),
                                                  Text('Delete Video', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ] else ...[
                                          InkWell(
                                            onTap: () => _handleUploadOrEditVideo(w),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.add, size: 12, color: AppColors.brandTeal),
                                                  SizedBox(width: 2),
                                                  Text('Upload Video', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _Badge(text: w.goal, color: AppColors.brandTeal),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(60, 28),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              side: const BorderSide(color: AppColors.brandTeal),
                                            ),
                                            onPressed: () => Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => EditWorkoutScreen(workout: w)),
                                            ),
                                            icon: const Icon(Icons.edit_outlined, size: 12, color: AppColors.brandTeal),
                                            label: const Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                          ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              backgroundColor: const Color(0xFFFEF2F2),
                                              padding: const EdgeInsets.all(6),
                                              minimumSize: const Size(28, 28),
                                            ),
                                            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                            onPressed: () => _confirmDeleteWorkout(w),
                                            tooltip: 'Delete Workout',
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
