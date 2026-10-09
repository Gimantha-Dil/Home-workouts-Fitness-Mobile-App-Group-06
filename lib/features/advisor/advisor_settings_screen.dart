import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_shell.dart';

class AdvisorSettingsScreen extends StatefulWidget {
  const AdvisorSettingsScreen({super.key});

  @override
  State<AdvisorSettingsScreen> createState() => _AdvisorSettingsScreenState();
}

class _AdvisorSettingsScreenState extends State<AdvisorSettingsScreen> {
  bool _consultationActive = true;
  final String _appearance = 'Light';
  String _language = 'English';

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _showSnack('Uploading profile picture to Supabase...');
        final bytes = await pickedFile.readAsBytes();
        final format = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';

        final publicUrl = await StorageService.uploadProfilePhoto(
          bytes: bytes,
          uid: user.id,
          format: format,
        );

        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
          'profilePhotoUrl': publicUrl,
        });

        final fbUser = fb.FirebaseAuth.instance.currentUser;
        if (fbUser != null) {
          await fbUser.updatePhotoURL(publicUrl);
          if (mounted) {
            await context.read<AuthProvider>().refreshUserFromFirestore(fbUser);
          }
        }

        if (mounted) {
          _showSnack('Profile picture updated successfully!');
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to upload profile photo: $e');
      }
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final controller = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Advisor Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Stack(
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.brandTeal,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await _pickAndUploadProfilePhoto();
                              if (mounted) _showEditProfileDialog(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && user != null) {
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(user.id).update({
                      'name': newName,
                    });
                    final fbUser = fb.FirebaseAuth.instance.currentUser;
                    if (fbUser != null) {
                      await fbUser.updateDisplayName(newName);
                      if (context.mounted) {
                        await context.read<AuthProvider>().refreshUserFromFirestore(fbUser);
                      }
                    }
                  } catch (_) {}
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _openNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Advisor Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Safety Alert Notifications: Enabled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('• User Consultation Inquiries: Enabled', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('• Protocol Review Alerts: Active', style: TextStyle(fontSize: 12, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
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

  void _openLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Sinhala (සිංහල)', 'Tamil (தமிழ்)'].map((l) {
            return RadioListTile<String>(
              title: Text(l, style: const TextStyle(fontSize: 13)),
              value: l,
              groupValue: _language,
              activeColor: AppColors.brandTeal,
              onChanged: (v) {
                setState(() => _language = v!);
                Navigator.of(ctx).pop();
                _showSnack('Language set to $_language');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openCredentialsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SLMC Credentials & Board Registry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SLMC Reg No: SLMC-89241 ✓ Verified', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
            SizedBox(height: 6),
            Text('Specialization: Sports Medicine & Physical Therapy', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('Affiliation: National Sports Clinic (Active)', style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openSafetyDefaultsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Safety Content Templates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Warm-up Duration: 6 mins (4 Steps)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• Cool-down Duration: 5–7 mins (4 Steps)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('• ACSM Red Flag Warnings: Active', style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold)),
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

  void _openPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Patient Health Privacy (HIPAA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Text(
          'All user consultation queries and health condition data are protected under HIPAA guidelines and encrypted using 256-bit data keys.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understand', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openHelpDeskSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Advisor Help Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Admin escalation & medical compliance support line.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Contact Clinical Compliance →',
              onPressed: () {
                Navigator.of(ctx).pop();
                _showSnack('Inquiry sent to Clinical Compliance Officer!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About FitPulse Healthcare Advisor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FitPulse Advisor v1.0.4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Clinical Licensure Terms & Board Governance', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('SLMC Accredited Node', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
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
                MaterialPageRoute(builder: (_) => const AdvisorShell()),
              );
            }
          },
        ),
        title: const Text('Advisor Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.shield_outlined, size: 20), onPressed: _openPrivacyDialog),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Card
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickAndUploadProfilePhoto(),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: ClipOval(
                            child: AppNetworkImage(
                              url: user?.profilePhotoUrl,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: AppColors.brandTeal,
                            child: Icon(Icons.camera_alt, size: 8, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user?.name ?? 'Healthcare Advisor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                              child: const Text('SLMC VERIFIED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                          ],
                        ),
                        Text(user?.email ?? 'advisor@example.com', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const Text('Sports Medicine Advisor', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.notifications_outlined,
              'Notifications',
              'Safety alerts, user queries & reviews',
              AppColors.warning,
              onTap: _openNotificationsDialog,
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: AppColors.brandTeal.withValues(alpha: 0.12), child: const Icon(Icons.medical_services_outlined, color: AppColors.brandTeal, size: 16)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consultation Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Available for user health reviews', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                    child: Text(_consultationActive ? '• Active' : 'Offline', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _consultationActive,
                    activeThumbColor: AppColors.brandTeal,
                    onChanged: (v) {
                      setState(() => _consultationActive = v);
                      _showSnack(v ? 'Consultation status: Active' : 'Consultation status: Offline');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            _settingTile(
              Icons.language_outlined,
              'Language',
              'System terminology & copy',
              AppColors.brandTeal,
              badge: _language,
              onTap: _openLanguageDialog,
            ),
            const SizedBox(height: 20),
            const Text('CLINICAL & SAFETY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.verified_user_outlined,
              'Credentials & Registration',
              'SLMC-89241, Sports Medicine Board',
              AppColors.brandTeal,
              onTap: _openCredentialsDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.shield_outlined,
              'Safety Content Defaults',
              'Warm-up, cooldown & precaution templates',
              AppColors.info,
              onTap: _openSafetyDefaultsDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.lock_outline,
              'Patient Health Privacy',
              'HIPAA compliance, 256-bit data keys',
              AppColors.purple,
              onTap: _openPrivacyDialog,
            ),
            const SizedBox(height: 20),
            const Text('SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.help_outline,
              'Advisor Help Desk',
              'Admin escalation & advisor guide',
              AppColors.warning,
              onTap: _openHelpDeskSheet,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.info_outline,
              'About FitPulse Advisor',
              'Version 1.0.4 • Clinical Licensure terms',
              AppColors.info,
              onTap: _openAboutDialog,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: InkWell(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final auth = context.read<AuthProvider>();
                  await auth.logout();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppRoot()),
                        (route) => false,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.danger, size: 18),
                    SizedBox(width: 8),
                    Text('Log Out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String sub, Color color, {String? badge, VoidCallback? onTap}) {
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
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
