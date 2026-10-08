import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/models/mock_data.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/history_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'customer_shell.dart';
import 'profile_setup_screen.dart';
import 'settings_screen.dart';
import 'workout_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _healthSyncActive = true;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _checkLostData();
    }
  }

  Future<void> _checkLostData() async {
    try {
      final picker = ImagePicker();
      final response = await picker.retrieveLostData();
      if (response.isEmpty || response.file == null) return;
      final file = response.file!;
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final bytes = await file.readAsBytes();
        final publicUrl = await StorageService.uploadProfilePhoto(
          bytes: bytes,
          uid: user.id,
          format: file.name.contains('.') ? file.name.split('.').last : 'jpg',
        );
        if (mounted) {
          await context.read<AuthProvider>().updateProfilePhoto(publicUrl);
          _showSnack('Profile picture updated successfully!');
        }
      }
    } catch (_) {}
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      _showSnack('No active user profile.');
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _uploadingPhoto = true);
        final bytes = await pickedFile.readAsBytes();

        final publicUrl = await StorageService.uploadProfilePhoto(
          bytes: bytes,
          uid: user.id,
          format: pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg',
        );

        if (mounted) {
          await context.read<AuthProvider>().updateProfilePhoto(publicUrl);
          _showSnack('Profile picture updated successfully!');
        }
      }
    } on PlatformException catch (e) {
      _showSnack('Permission denied or photo access unavailable: ${e.message}');
    } catch (e) {
      _showSnack('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  void _openHealthSyncDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.sync, color: AppColors.brandTeal, size: 22),
              SizedBox(width: 8),
              Text('Health App Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _healthSyncActive ? const Color(0xFFF0FDF4) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _healthSyncActive ? const Color(0xFFBBF7D0) : const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _healthSyncActive ? Icons.check_circle : Icons.pause_circle_outline,
                      color: _healthSyncActive ? AppColors.success : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_healthSyncActive ? 'Apple Health & Google Fit Synced' : 'Sync Paused', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(_healthSyncActive ? 'Step count, resting heart rate, active calories' : 'Turn on below to auto-import daily steps', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Auto-Sync Heart Rate Telemetry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _healthSyncActive,
                    activeColor: AppColors.brandTeal,
                    onChanged: (v) {
                      setDialogState(() => _healthSyncActive = v);
                      setState(() => _healthSyncActive = v);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: () {
                Navigator.of(ctx).pop();
                _showSnack('Health telemetry synced successfully!');
              },
              child: const Text('Sync Now 🔄', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openOfflineWorkoutsDialog() {
    final offlineSessions = MockData.workouts.take(3).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_done, color: AppColors.info, size: 22),
            SizedBox(width: 8),
            Text('Offline Workouts (3)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('These sessions are fully downloaded and can be started without internet access:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ...offlineSessions.map((w) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      const Icon(Icons.offline_pin, color: AppColors.info, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('${w.durationMinutes} min • ${w.level}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandTeal,
                          minimumSize: const Size(50, 26),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: w)));
                        },
                        child: const Text('Play', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _openMedicalClearanceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: AppColors.success, size: 22),
            SizedBox(width: 8),
            Text('Medical Clearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CLINICAL CARDIOLOGY CLEARANCE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                  SizedBox(height: 4),
                  Text('Certified Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.success)),
                  SizedBox(height: 4),
                  Text('Dr. Silva, MD (Cardiology) • SLMC #48921', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 6),
                  Text('Cleared for beginner to intermediate aerobic exertion up to 155 BPM safety threshold.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
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
                MaterialPageRoute(builder: (_) => const CustomerShell()),
              );
            }
          },
        ),
        title: const Row(
          children: [
            Text('Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('FITPULSE MEMBER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadingPhoto ? null : _pickAndUploadAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
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
                          decoration: const BoxDecoration(color: AppColors.brandTeal, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user?.name ?? 'FitPulse User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, color: AppColors.brandTeal, size: 16),
                    ],
                  ),
                  Text(user?.email ?? 'user@example.com', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(20)),
                    child: Text('★ MEMBER • ${user?.role.name.toUpperCase() ?? "CUSTOMER"}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real Progress Stats Row
            Consumer<HistoryProvider>(
              builder: (context, history, _) {
                return Row(
                  children: [
                    Expanded(child: _ProfileStat(value: '${history.totalSessions}', label: 'WORKOUTS', icon: Icons.fitness_center, color: AppColors.info)),
                    const SizedBox(width: 8),
                    Expanded(child: _ProfileStat(value: '${history.streakDays}', label: 'DAY STREAK', icon: Icons.local_fire_department, color: AppColors.warning)),
                    const SizedBox(width: 8),
                    Expanded(child: _ProfileStat(value: '${history.totalCaloriesBurned}', label: 'TOTAL KCAL', icon: Icons.bolt, color: AppColors.purple)),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Real Fitness Baselines Card from Firestore
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(user?.id ?? '').snapshots(),
              builder: (context, docSnap) {
                final data = docSnap.data?.data();
                final profile = data?['profile'] as Map<String, dynamic>?;
                final goalsList = (data?['goals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                final targetFocus = goalsList.isNotEmpty ? goalsList.first : 'General Fitness';

                final height = profile?['height']?.toString() ?? '160 cm';
                final weight = profile?['weight']?.toString() ?? '80.0 kg';
                final level = profile?['fitnessLevel']?.toString() ?? 'Beginner';

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fitness Baselines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('• Clinical Sync', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MetricItem(label: 'HEIGHT', value: height),
                          _MetricItem(label: 'WEIGHT', value: weight),
                          _MetricItem(label: 'FITNESS LEVEL', value: level),
                          _MetricItem(label: 'TARGET FOCUS', value: targetFocus),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandTeal,
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen())),
                          child: const Text('Update Biometrics & Goals →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _settingTile(Icons.sync, 'Health App Sync', _healthSyncActive ? 'Apple Health & Google Fit • ACTIVE' : 'Sync Paused', AppColors.brandTeal, _openHealthSyncDialog),
            const SizedBox(height: 8),
            _settingTile(Icons.download_done, 'Offline Workouts', '3 sessions available offline', AppColors.info, _openOfflineWorkoutsDialog),
            const SizedBox(height: 8),
            _settingTile(Icons.verified, 'Medical Clearance', 'Certified by Dr. Silva (Cardiology)', AppColors.success, _openMedicalClearanceDialog),
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
            const Center(
              child: Text('FitPulse Advisor Pro • Build 4.12.0', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 12),
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

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _ProfileStat({required this.value, required this.label, required this.icon, required this.color});

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

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
