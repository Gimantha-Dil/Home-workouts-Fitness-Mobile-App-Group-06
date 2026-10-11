import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_settings_screen.dart';
import 'trainer_shell.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  void _showEditProfileSheet(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final nameController = TextEditingController(text: user?.name ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Trainer Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        child: ClipOval(
                          child: AppNetworkImage(
                            url: user?.profilePhotoUrl,
                            width: 72,
                            height: 72,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          try {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                              withData: true,
                            );

                            if (result != null && result.files.isNotEmpty) {
                              final picked = result.files.first;
                              List<int>? bytes = picked.bytes;
                              if (bytes == null && !kIsWeb && picked.path != null) {
                                bytes = await File(picked.path!).readAsBytes();
                              }
                              if (bytes != null) {
                                final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                final photoUrl = await SupabaseService.uploadUserPhoto(
                                  fileName: fileName,
                                  photoBytes: bytes,
                                );
                                if (ctx.mounted) {
                                  final messenger = ScaffoldMessenger.of(ctx);
                                  await ctx.read<AuthProvider>().updateProfilePhoto(photoUrl);
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('⚡ Profile photo updated!'), backgroundColor: AppColors.brandTeal),
                                  );
                                }
                              }
                            }
                          } catch (e) {
                            debugPrint('Photo upload error: $e');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.brandTeal, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Tap camera icon to change photo', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Trainer Name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Save Changes',
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && user != null) {
                  try {
                    await SupabaseService.saveUserToSupabase(
                      uid: user.id,
                      name: newName,
                      email: user.email,
                      role: user.role,
                    );
                  } catch (_) {}
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    context.watch<LanguageProvider>(); // Listen to language updates

    final isVerified = user?.verificationStatus == 'approved';

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
        title: Text(context.tr('trainer_profile'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainerSettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Workout>>(
          stream: SupabaseService.streamWorkoutsFromSupabase(),
          builder: (context, snapshot) {
            final workouts = snapshot.data ?? [];
            final totalCreated = workouts.length;
            final activePublished = workouts.where((w) => w.isPublished).length;
            final pendingQA = workouts.where((w) => !w.isPublished).length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: ClipOval(
                              child: AppNetworkImage(
                                url: user?.profilePhotoUrl,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isVerified ? AppColors.brandTeal : AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isVerified ? Icons.check : Icons.access_time, color: Colors.white, size: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(user?.name ?? 'Fitness Trainer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          _Chip(label: 'Bodyweight', color: AppColors.brandTeal),
                          _Chip(label: 'Mobility', color: AppColors.info),
                          _Chip(label: 'Hypertrophy', color: AppColors.purple),
                          _Chip(label: 'Posture', color: AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Certified Fitness Trainer & Kinesiologist', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        isVerified ? '• Verified Professional' : '• Verification Pending Admin Review',
                        style: TextStyle(
                          fontSize: 10,
                          color: isVerified ? AppColors.brandTeal : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 140,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: AppColors.brandTeal),
                          ),
                          onPressed: () => _showEditProfileSheet(context),
                          child: const Text('Edit Profile ✏', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Realtime Stats Row Streamed from Supabase
                Row(
                  children: [
                    Expanded(child: _TrainerStat(value: '$totalCreated', label: 'Created', icon: Icons.fitness_center, color: AppColors.info)),
                    const SizedBox(width: 8),
                    Expanded(child: _TrainerStat(value: '$activePublished', label: 'Active', icon: Icons.check_circle_outline, color: AppColors.success)),
                    const SizedBox(width: 8),
                    Expanded(child: _TrainerStat(value: '$pendingQA', label: 'Pending QA', icon: Icons.hourglass_top, color: AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 16),

                // About Trainer Card
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About ${user?.name.split(' ').first ?? 'Trainer'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      const Text(
                        'Certified Fitness Trainer dedicated to creating high-impact home workout routines, functional mobility flows, and progressive strength conditioning for trainees.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('2 Active', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                _certTile('ACE Certified Personal Trainer', 'American Council on Exercise • Valid thru 2026'),
                const SizedBox(height: 8),
                _certTile('NASM Corrective Exercise Specialist', 'National Academy of Sports Medicine'),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Assigned Modules / Routines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('$totalCreated Total', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),

                if (workouts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No workout modules built yet.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  )
                else
                  ...workouts.take(3).map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _moduleTile(w.title, 'Level: ${w.level} • ${w.exercises.length} exercises • ${w.durationMinutes} min'),
                  )),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final auth = context.read<AuthProvider>();
                      await auth.logout();
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AppRoot()),
                        (route) => false,
                      );
                    },
                    child: const Text('Sign Out of FitPulse', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _certTile(String title, String sub) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.verified, color: AppColors.brandTeal, size: 16)),
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
          const Icon(Icons.check_circle, color: AppColors.brandTeal, size: 16),
        ],
      ),
    );
  }

  Widget _moduleTile(String title, String sub) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(width: 40, height: 40, color: Colors.grey.shade200, child: const Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 18)),
          ),
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
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _TrainerStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _TrainerStat({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
