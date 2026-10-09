import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/exercise_video_player.dart';
import 'advisor_settings_screen.dart';
import 'advisor_shell.dart';

class SafetyContentScreen extends StatefulWidget {
  const SafetyContentScreen({super.key});

  @override
  State<SafetyContentScreen> createState() => _SafetyContentScreenState();
}

class _SafetyContentScreenState extends State<SafetyContentScreen> {
  int _tab = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.brandTeal, duration: const Duration(seconds: 2)),
    );
  }

  void _showAddOrEditGuidanceDialog(Workout workout, [AdvisorGuideline? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? 'Doctor Verified Warm-up Recommended');
    final instructionCtrl = TextEditingController(text: existing?.instruction ?? 'Complete 3–5 minutes of light arm circles and high knees before starting to prevent joint strain.');

    showDialog(
      context: context,
      builder: (ctx) {
        final user = context.read<AuthProvider>().currentUser;
        final advisorName = user?.name ?? 'Dr. Medical Advisor';

        return AlertDialog(
          title: Text(existing != null ? 'Edit Safety Guidance' : 'Attach Safety Guidance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Routine: ${workout.title}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
              Text('Trainer: ${workout.createdByName}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Guidance Header Title *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'e.g. Doctor Verified Warm-up Recommended')),
              const SizedBox(height: 12),
              const Text('Clinical Safety Instruction *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: instructionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Write clinical warm-up, joint safety or exertion advice for trainees...'),
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
                final instruction = instructionCtrl.text.trim();
                if (title.isEmpty || instruction.isEmpty) return;

                final newGuideline = AdvisorGuideline(
                  id: existing?.id ?? 'guide_${DateTime.now().millisecondsSinceEpoch}',
                  workoutId: workout.id,
                  advisorUid: user?.id ?? 'adv_101',
                  advisorName: advisorName,
                  advisorSpecialty: 'Sports Medicine & Cardiology',
                  title: title,
                  instruction: instruction,
                );

                // Update Firestore Workout Document
                final updatedGuidelines = List<AdvisorGuideline>.from(workout.advisorGuidelines);
                if (existing != null) {
                  final idx = updatedGuidelines.indexWhere((g) => g.id == existing.id);
                  if (idx != -1) updatedGuidelines[idx] = newGuideline;
                } else {
                  updatedGuidelines.add(newGuideline);
                }

                try {
                  await FirebaseFirestore.instance.collection('workouts').doc(workout.id).set({
                    'advisorGuidelines': updatedGuidelines.map((g) => g.toMap()).toList(),
                  }, SetOptions(merge: true));

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _showSnack('Safety guidance updated by $advisorName in real-time!');
                } catch (e) {
                  debugPrint('Error attaching safety guidance: $e');
                }
              },
              child: const Text('Save Guidance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deleteGuidance(Workout workout, AdvisorGuideline guideline) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Safety Guidance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Remove "${guideline.title}" by ${guideline.advisorName} from this workout?', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final updatedGuidelines = List<AdvisorGuideline>.from(workout.advisorGuidelines)
                ..removeWhere((g) => g.id == guideline.id);

              try {
                await FirebaseFirestore.instance.collection('workouts').doc(workout.id).set({
                  'advisorGuidelines': updatedGuidelines.map((g) => g.toMap()).toList(),
                }, SetOptions(merge: true));

                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack('Safety guidance removed from workout.');
              } catch (e) {
                debugPrint('Error deleting guideline: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AdvisorShell()),
              );
            }
          },
        ),
        title: const Text('Safety Content & Workout Guidelines', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdvisorSettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('workouts').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => Workout.fromMap({'id': d.id, ...d.data()})).toList() ?? [];

            // Category Filter
            var filtered = docs;
            if (_tab == 1) {
              filtered = filtered.where((w) => w.level.toLowerCase().contains('begin')).toList();
            } else if (_tab == 2) {
              filtered = filtered.where((w) => w.level.toLowerCase().contains('interm')).toList();
            } else if (_tab == 3) {
              filtered = filtered.where((w) => w.level.toLowerCase().contains('adv')).toList();
            }

            // Real-Time Search Filter
            final q = _searchQuery.trim().toLowerCase();
            if (q.isNotEmpty) {
              filtered = filtered.where((w) {
                final title = w.title.toLowerCase();
                final trainer = w.createdByName.toLowerCase();
                final level = w.level.toLowerCase();
                return title.contains(q) || trainer.contains(q) || level.contains(q);
              }).toList();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text('Supervise Trainer Workouts & Attach Clinical Safety Guidelines', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 14),

                      // Instant Real-time Search Input Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search workouts or trainers...',
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

                      // Category Tabs
                      Row(
                        children: [
                          Expanded(child: _tabBtn('All (${docs.length})', 0)),
                          const SizedBox(width: 6),
                          Expanded(child: _tabBtn('Beginner', 1)),
                          const SizedBox(width: 6),
                          Expanded(child: _tabBtn('Intermediate', 2)),
                          const SizedBox(width: 6),
                          Expanded(child: _tabBtn('Advanced', 3)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SHOWING ${filtered.length} ROUTINES', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                          const Text('• Live Firestore DB', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No workouts found matching "$_searchQuery".'
                                  : 'No trainer workouts published in Firestore yet.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((w) {
                          final videoUrlToPlay = (w.videoUrl != null && w.videoUrl!.trim().isNotEmpty && w.videoUrl!.trim().startsWith('http'))
                              ? w.videoUrl!.trim()
                              : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
                          final hasGuidance = w.advisorGuidelines.isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Color(0xFFCCFBF1),
                                        child: Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 20),
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                                                  child: const Text('TRAINER VIDEO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text('Trainer: ${w.createdByName} • ${w.level} • ${w.durationMinutes} min', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Embedded Trainer MP4 Video Streaming Player
                                  ExerciseVideoPlayer(
                                    videoUrl: videoUrlToPlay,
                                    title: '${w.title} (by ${w.createdByName})',
                                  ),
                                  const SizedBox(height: 10),

                                  // Display Attached Advisor Guidelines
                                  if (hasGuidance) ...[
                                    ...w.advisorGuidelines.map((g) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFBBF7D0)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.verified, color: AppColors.brandTeal, size: 14),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${g.title} • By ${g.advisorName}',
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => _showAddOrEditGuidanceDialog(w, g),
                                                  child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.brandTeal),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () => _deleteGuidance(w, g),
                                                  child: const Icon(Icons.delete_outline, size: 14, color: AppColors.danger),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(g.instruction, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],

                                  // Add Guidance Button
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.brandTeal,
                                      side: const BorderSide(color: AppColors.brandTeal),
                                      minimumSize: const Size.fromHeight(34),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showAddOrEditGuidanceDialog(w),
                                    icon: const Icon(Icons.verified_user_outlined, size: 14),
                                    label: Text(
                                      hasGuidance ? '+ Add Another Safety Guidance' : 'Attach Medical Safety Guidance',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 12),
                      // Clinical Reminder Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.brandTeal, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Clinical Reminder: Guidance instructions attached here will appear in real-time on trainees\' Workout Details screens.',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                            ),
                          ],
                        ),
                      ),
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
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
