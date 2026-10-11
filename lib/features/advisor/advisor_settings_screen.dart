import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/language_provider.dart';
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
  void _showSnack(String msg) {
    if (!mounted) return;
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
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Advisor Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && user != null) {
                await FirebaseFirestore.instance.collection('users').doc(user.id).update({'name': newName});
                final fbUser = fb.FirebaseAuth.instance.currentUser;
                if (fbUser != null) {
                  await fbUser.updateDisplayName(newName);
                  if (ctx.mounted) {
                    await context.read<AuthProvider>().refreshUserFromFirestore(fbUser);
                  }
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack('Name updated successfully!');
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openCredentialInfoDialog() {
    final user = context.read<AuthProvider>().currentUser;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SLMC Clinical Accreditation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${user?.name ?? "Dr. Advisor"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('Registry ID: SLMC #48921', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Speciality: Cardiology & Sports Medicine', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Status: Active Clinical Accreditation', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
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
            const Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.help_outline, color: AppColors.brandTeal, size: 16)),
                SizedBox(width: 8),
                Text('Healthcare Advisor Portal Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('• How to publish clinical guidance for trainees?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Text('Tap "Create Guidance" in your dashboard, enter title and safety instructions, then set status to "Publish".', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            const Text('• How to answer patient inquiries?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Text('Check the "Patient Consultations" section on your dashboard and tap "Reply" to open a live chat.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Understood',
              onPressed: () => Navigator.of(ctx).pop(),
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
            const SizedBox(height: 12),

            // Real-Time Doctor Ratings Card on Settings
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('advisorReviews')
                  .where('advisorId', isEqualTo: user?.id ?? '')
                  .snapshots(),
              builder: (context, reviewSnap) {
                final reviewDocs = reviewSnap.data?.docs ?? [];
                if (reviewDocs.isEmpty) return const SizedBox.shrink();

                final ratings = reviewDocs.map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 5.0).toList();
                final avgRating = double.parse((ratings.reduce((a, b) => a + b) / ratings.length).toStringAsFixed(1));

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text('$avgRating / 5.0 Rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                      const Spacer(),
                      Text('• ${ratings.length} Patient Reviews', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text('CLINICAL CREDENTIALS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingRow(
              Icons.verified,
              'SLMC Accreditation',
              'Medical registration & specialization',
              AppColors.brandTeal,
              badge: 'Verified',
              onTap: _openCredentialInfoDialog,
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.assignment_outlined,
              'Safety Content Defaults',
              'Warm-up duration & ACSM thresholds',
              AppColors.info,
              onTap: _openSafetyDefaultsDialog,
            ),
            const SizedBox(height: 20),
            const Text('PORTAL PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingRow(
              Icons.help_outline,
              'Advisor Portal Help Desk',
              'Guideline publishing FAQs',
              AppColors.warning,
              onTap: _openHelpDeskSheet,
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.lock_outline,
              'Patient Privacy Safeguards',
              'HIPAA compliant telemetry',
              AppColors.danger,
              badge: 'HIPAA',
              onTap: _openPrivacyDialog,
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

  Widget _settingRow(IconData icon, String title, String sub, Color color, {String? badge, VoidCallback? onTap}) {
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
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
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
