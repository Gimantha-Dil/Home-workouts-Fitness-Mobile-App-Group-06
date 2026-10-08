import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class TrainerVerificationScreen extends StatefulWidget {
  const TrainerVerificationScreen({super.key});

  @override
  State<TrainerVerificationScreen> createState() => _TrainerVerificationScreenState();
}

class _TrainerVerificationScreenState extends State<TrainerVerificationScreen> {
  String _experience = '3 - 5 Years (Active Coaching)';
  final _socialController = TextEditingController(text: 'https://instagram.com/alex_fitpulse');

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 24),
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
              // Centered Title & Stage Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
              _uploadTile('FITNESS CERTIFICATIONS', 'ace_trainer_cert.pdf', '2.4 MB • Verified format', 'REQUIRED', 'Replace'),
              const SizedBox(height: 18),

              // Experience Dropdown Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
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
                    onChanged: (v) => setState(() => _experience = v!),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Document Upload 2 (Identity Verification)
              _uploadTile('IDENTITY VERIFICATION (NIC)', 'trainer_nic_scan.pdf', '1.8 MB • Encrypted document', 'REQUIRED', 'Upload'),
              const SizedBox(height: 18),

              // Social Links Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('PROFESSIONAL / SOCIAL LINKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('OPTIONAL', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _socialController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link, size: 22),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Admin Notice Info Box (Centered)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: const [
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

              // Primary Action Button (Centered Text, Larger Font)
              PrimaryButton(
                label: 'SUBMIT FOR VERIFICATION →',
                onPressed: () {
                  context.read<AuthProvider>().login(email: 'trainer@fitpulse.com', role: UserRole.trainer);
                },
              ),
              const SizedBox(height: 12),

              // Save Draft Link (Centered)
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('SAVE DRAFT', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadTile(String label, String fileName, String sub, String badge, String actionText) {
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
              _Badge(text: badge, color: AppColors.danger),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⚡ Document "$fileName" uploaded to Supabase Storage (verification-docs)!'),
                      backgroundColor: AppColors.brandTeal,
                    ),
                  );
                },
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
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
