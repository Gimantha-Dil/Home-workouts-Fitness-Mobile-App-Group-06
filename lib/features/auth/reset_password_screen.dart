import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showSnack('Please enter a valid registered email address.');
      return;
    }

    setState(() => _loading = true);
    final error = await context.read<AuthProvider>().resetPassword(email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showSnack(error);
    } else {
      setState(() => _sent = true);
      _showSnack('Password reset link sent to $email');
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            AppLogoIcon(size: 26),
            SizedBox(width: 8),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Your Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your registered email address and we will send you a password reset link.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                enabled: !_loading && !_sent,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your registered email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 24),
              if (_sent) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Password reset link sent to your email. Check your inbox to set a new password.',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Back to Log In →',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  PrimaryButton(
                    label: 'Send Reset Link →',
                    onPressed: _handleReset,
                  ),
              ],
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
          ),
        ),
      ),
    );
  }
}
