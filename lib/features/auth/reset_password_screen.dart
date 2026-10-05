import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  int _step = 1;
  String _sendMethod = 'email';
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: const [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 24),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.security, size: 12, color: AppColors.brandTeal),
                SizedBox(width: 4),
                Text('SECURE', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 1 ? _buildStep1(context) : _buildStep2(context),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset Your Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose where to receive your verification code and create your new secure password.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('1. SEND VERIFICATION CODE VIA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            Text('STEP 1 OF 2', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _sendMethod = 'email'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _sendMethod == 'email' ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _sendMethod == 'email' ? AppColors.brandTeal : const Color(0xFFE5E7EB), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.email_outlined, color: AppColors.brandTeal, size: 20),
                      SizedBox(height: 8),
                      Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('a***n@example.com', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _sendMethod = 'phone'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _sendMethod == 'phone' ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _sendMethod == 'phone' ? AppColors.brandTeal : const Color(0xFFE5E7EB), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.phone_android_outlined, color: AppColors.brandTeal, size: 20),
                      SizedBox(height: 8),
                      Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('+1 (***) ***-8924', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Code will be sent to registered Email:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('Change', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter 6-digit code',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandTeal,
                      minimumSize: const Size(100, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text('Get Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text('Code expires in ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('10 minutes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Next Step →',
          onPressed: () => setState(() => _step = 2),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Remember your password? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text('Log In', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('2. SET NEW PASSWORD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            Text('STEP 2 OF 2', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter new strong password',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: Icon(Icons.visibility_off_outlined),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Re-enter New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Confirm your new password',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: Icon(Icons.visibility_off_outlined),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('PASSWORD REQUIREMENTS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              SizedBox(height: 8),
              _RequirementRow(text: 'At least 8 characters long'),
              SizedBox(height: 6),
              _RequirementRow(text: 'Contains at least one number & symbol'),
              SizedBox(height: 6),
              _RequirementRow(text: 'Both passwords must match'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Update Password & Log In →',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String text;
  const _RequirementRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 14, color: AppColors.success),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
