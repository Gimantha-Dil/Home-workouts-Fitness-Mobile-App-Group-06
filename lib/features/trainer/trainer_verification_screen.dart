import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_shell.dart';

class TrainerVerificationScreen extends StatefulWidget {
  const TrainerVerificationScreen({super.key});

  @override
  State<TrainerVerificationScreen> createState() => _TrainerVerificationScreenState();
}

class _TrainerVerificationScreenState extends State<TrainerVerificationScreen> {
  String _experience = '3 - 5 Years (Active Coaching)';
  final _socialController = TextEditingController();

  PlatformFile? _certFile;
  PlatformFile? _nicFile;

  bool _loading = false;
  String _uploadStatus = '';

  @override
  void dispose() {
    _socialController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _pickDocument(bool isCert) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          if (isCert) {
            _certFile = result.files.first;
          } else {
            _nicFile = result.files.first;
          }
        });
      }
    } catch (e) {
      _showSnack('File picking failed: $e');
    }
  }

  Future<void> _submitVerification() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      _showSnack('No active user found. Please sign up or log in first.');
      return;
    }

    if (_certFile == null) {
      _showSnack('Please select your Fitness Certifications document.');
      return;
    }

    setState(() {
      _loading = true;
      _uploadStatus = 'Uploading documents to Supabase Storage...';
    });

    try {
      final uid = fbUser.uid;
      final docUrls = <String>[];

      if (_certFile != null && _certFile!.bytes != null) {
        final url = await StorageService.uploadVerificationDoc(
          bytes: _certFile!.bytes!,
          uid: uid,
          fileName: _certFile!.name,
        );
        docUrls.add(url);
      }

      if (_nicFile != null && _nicFile!.bytes != null) {
        final url = await StorageService.uploadVerificationDoc(
          bytes: _nicFile!.bytes!,
          uid: uid,
          fileName: _nicFile!.name,
        );
        docUrls.add(url);
      }

      setState(() => _uploadStatus = 'Submitting request to Firestore...');

      final firestore = FirebaseFirestore.instance;

      // Create Verification Request
      await firestore.collection('verificationRequests').doc(uid).set({
        'uid': uid,
        'requestedRole': 'trainer',
        'documentUrls': docUrls,
        'experienceYears': _experience,
        'socialLink': _socialController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update User role and verification status
      await firestore.collection('users').doc(uid).set({
        'role': 'trainer',
        'verificationStatus': 'pending',
      }, SetOptions(merge: true));

      if (mounted) {
        await context.read<AuthProvider>().refreshUserFromFirestore(fbUser);
      }

      if (!mounted) return;
      setState(() => _loading = false);

      _showSnack('Verification request submitted successfully!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrainerShell()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Submission failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 24),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            _Badge(text: 'TRAINER', color: AppColors.brandTeal),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(20)),
            child: const Text('02 / 02', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('VERIFICATION', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5)),
                  SizedBox(width: 8),
                  _Badge(text: 'FINAL STAGE', color: AppColors.brandTeal),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Step 2: Submit professional credentials',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              // Document Upload 1 (Fitness Certifications)
              _uploadTile(
                label: 'FITNESS CERTIFICATIONS',
                fileName: _certFile != null ? _certFile!.name : 'No file selected',
                sub: _certFile != null ? '${(_certFile!.size / 1024 / 1024).toStringAsFixed(1)} MB • Selected' : 'PDF / JPG / PNG max 10 MB',
                badge: _certFile != null ? 'READY' : 'REQUIRED',
                badgeColor: _certFile != null ? AppColors.success : AppColors.danger,
                actionText: _certFile != null ? 'Change' : 'Select File',
                onAction: () => _pickDocument(true),
              ),
              const SizedBox(height: 18),

              // Experience Dropdown Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('EXPERIENCE (YEARS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('SELECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _experience,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    items: const ['1 - 2 Years', '3 - 5 Years (Active Coaching)', '5+ Years Specialist']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))))
                        .toList(),
                    onChanged: _loading ? null : (v) => setState(() => _experience = v!),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Document Upload 2 (Identity Verification)
              _uploadTile(
                label: 'IDENTITY VERIFICATION (NIC / PASSPORT)',
                fileName: _nicFile != null ? _nicFile!.name : 'No file selected',
                sub: _nicFile != null ? '${(_nicFile!.size / 1024 / 1024).toStringAsFixed(1)} MB • Selected' : 'PDF / JPG / PNG max 10 MB',
                badge: _nicFile != null ? 'READY' : 'OPTIONAL',
                badgeColor: _nicFile != null ? AppColors.success : AppColors.brandTeal,
                actionText: _nicFile != null ? 'Change' : 'Select File',
                onAction: () => _pickDocument(false),
              ),
              const SizedBox(height: 18),

              // Social Links Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PROFESSIONAL / SOCIAL LINKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('OPTIONAL', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _socialController,
                    enabled: !_loading,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'https://instagram.com/your_profile',
                      prefixIcon: Icon(Icons.link, size: 22),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Admin Notice Info Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.info, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin verifies credentials in 24h. You will receive an in-app notice once your badge is activated.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_loading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text(_uploadStatus, style: const TextStyle(fontSize: 12, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ] else
                PrimaryButton(
                  label: 'SUBMIT FOR VERIFICATION →',
                  onPressed: _submitVerification,
                ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                  child: const Text('CANCEL / BACK', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadTile({
    required String label,
    required String fileName,
    required String sub,
    required String badge,
    required Color badgeColor,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
              _Badge(text: badge, color: badgeColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, color: AppColors.brandTeal, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: AppColors.brandTeal),
                ),
                onPressed: _loading ? null : onAction,
                child: Text(actionText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
