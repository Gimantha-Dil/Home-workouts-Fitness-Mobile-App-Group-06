import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_shell.dart';

class AdvisorVerificationScreen extends StatefulWidget {
  const AdvisorVerificationScreen({super.key});

  @override
  State<AdvisorVerificationScreen> createState() => _AdvisorVerificationScreenState();
}

class _AdvisorVerificationScreenState extends State<AdvisorVerificationScreen> {
  final _regNoController = TextEditingController();
  final _workplaceController = TextEditingController();
  String _specialization = 'Sports Medicine & Physical Therapy';

  PlatformFile? _idFile;
  PlatformFile? _degreeFile;

  bool _loading = false;
  String _uploadStatus = '';

  @override
  void dispose() {
    _regNoController.dispose();
    _workplaceController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _pickDocument(bool isId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          if (isId) {
            _idFile = result.files.first;
          } else {
            _degreeFile = result.files.first;
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

    final regNo = _regNoController.text.trim();
    final workplace = _workplaceController.text.trim();

    if (regNo.isEmpty) {
      _showSnack('Please enter your Medical Council Registration Number.');
      return;
    }

    if (workplace.isEmpty) {
      _showSnack('Please enter your affiliated workplace or hospital.');
      return;
    }

    if (_degreeFile == null) {
      _showSnack('Please select your Board Certifications document.');
      return;
    }

    setState(() {
      _loading = true;
      _uploadStatus = 'Uploading documents to Supabase Storage...';
    });

    try {
      final uid = fbUser.uid;
      final docUrls = <String>[];

      if (_idFile != null && _idFile!.bytes != null) {
        final url = await StorageService.uploadVerificationDoc(
          bytes: _idFile!.bytes!,
          uid: uid,
          fileName: _idFile!.name,
        );
        docUrls.add(url);
      }

      if (_degreeFile != null && _degreeFile!.bytes != null) {
        final url = await StorageService.uploadVerificationDoc(
          bytes: _degreeFile!.bytes!,
          uid: uid,
          fileName: _degreeFile!.name,
        );
        docUrls.add(url);
      }

      setState(() => _uploadStatus = 'Submitting request to Firestore...');

      final firestore = FirebaseFirestore.instance;

      // Create Verification Request
      await firestore.collection('verificationRequests').doc(uid).set({
        'uid': uid,
        'requestedRole': 'advisor',
        'documentUrls': docUrls,
        'registrationNumber': regNo,
        'specialization': _specialization,
        'workplace': workplace,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update User role and verification status
      await firestore.collection('users').doc(uid).set({
        'role': 'advisor',
        'verificationStatus': 'pending',
      }, SetOptions(merge: true));

      if (mounted) {
        await context.read<AuthProvider>().refreshUserFromFirestore(fbUser);
      }

      if (!mounted) return;
      setState(() => _loading = false);

      _showSnack('Verification request submitted successfully!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdvisorShell()),
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
            _Badge(text: 'FITPULSE ADVISOR', color: AppColors.brandTeal),
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
              const Text('Clinical Credentials', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              const Text(
                'Step 2: Enter medical registration and upload clinical board certifications.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              // Registration No Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('REGISTRATION NO.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('REQUIRED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _regNoController,
                    enabled: !_loading,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'e.g. SLMC-89241',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      suffixIcon: Icon(Icons.check_circle, color: AppColors.brandTeal, size: 22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('✓ Medical Council Registry format', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 18),

              // Specialization Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SPECIALIZATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('SELECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _specialization,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
                    items: const [
                      'Sports Medicine & Physical Therapy',
                      'General Health & Cardiology',
                      'Nutrition & Metabolic Health',
                      'Orthopedics & Joint Care'
                    ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                    onChanged: _loading ? null : (v) => setState(() => _specialization = v!),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Workplace Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AFFILIATED WORKPLACE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('REQUIRED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _workplaceController,
                    enabled: !_loading,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Hospital or Clinic Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Document Upload Cards
              _uploadTile(
                label: 'IDENTITY PROOF (NIC / PASSPORT)',
                fileName: _idFile != null ? _idFile!.name : 'No file selected',
                sub: _idFile != null ? '${(_idFile!.size / 1024 / 1024).toStringAsFixed(1)} MB • Selected' : 'PDF / JPG / PNG max 10 MB',
                badge: _idFile != null ? 'READY' : 'OPTIONAL',
                badgeColor: _idFile != null ? AppColors.success : AppColors.brandTeal,
                actionText: _idFile != null ? 'Change' : 'Select File',
                onAction: () => _pickDocument(true),
              ),
              const SizedBox(height: 12),
              _uploadTile(
                label: 'BOARD CERTIFICATIONS',
                fileName: _degreeFile != null ? _degreeFile!.name : 'No file selected',
                sub: _degreeFile != null ? '${(_degreeFile!.size / 1024 / 1024).toStringAsFixed(1)} MB • Selected' : 'PDF / JPG / PNG max 10 MB',
                badge: _degreeFile != null ? 'READY' : 'REQUIRED',
                badgeColor: _degreeFile != null ? AppColors.success : AppColors.danger,
                actionText: _degreeFile != null ? 'Change' : 'Select File',
                onAction: () => _pickDocument(false),
              ),
              const SizedBox(height: 20),

              // Fast-Track Verification Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fast-Track Clinical Verification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.info)),
                          SizedBox(height: 2),
                          Text('Credentials reviewed within 24 hours by medical compliance.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                        ],
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
                  label: 'Submit Clinical Credentials →',
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
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
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
