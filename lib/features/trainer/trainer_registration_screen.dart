import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_verification_screen.dart';

class TrainerRegistrationScreen extends StatefulWidget {
  const TrainerRegistrationScreen({super.key});

  @override
  State<TrainerRegistrationScreen> createState() => _TrainerRegistrationScreenState();
}

class _TrainerRegistrationScreenState extends State<TrainerRegistrationScreen> {
  final _nameController = TextEditingController(text: 'Alex Carter');
  final _emailController = TextEditingController(text: 'alex.carter@fitpulse.com');
  final _passwordController = TextEditingController(text: 'SuperSecurePass123!');
  final _confirmPasswordController = TextEditingController(text: 'SuperSecurePass123!');
  bool _obscure = true;
  bool _agreeTerms = true;
  bool _isSignUp = true;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  void _loginWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final googleUser = await GoogleAuthService.handleGoogleSignIn(
      context: context,
      role: UserRole.trainer,
    );
    if (googleUser != null && mounted) {
      authProvider.login(
        email: googleUser.email,
        name: googleUser.name,
        role: googleUser.role,
      );
    }
  }

  void _submitAction() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter your email address.');
      return;
    }

    if (_isSignUp) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TrainerVerificationScreen()),
      );
    } else {
      context.read<AuthProvider>().login(
        email: email,
        role: email.toLowerCase() == 'gimantha333@gmail.com' ? UserRole.admin : UserRole.trainer,
      );
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
        title: Row(
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
            child: const Text('Step 1 of 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(text: 'TRAINER CERTIFICATION PORTAL', color: AppColors.brandTeal),
              const SizedBox(height: 8),
              Text(_isSignUp ? 'Trainer Sign Up' : 'Trainer Log In', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text(
                'Create your professional coaching profile to publish workouts, share video demonstrations, and coach clients.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),
              // Tab Selector [ Log In | Sign Up ]
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSignUp = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isSignUp ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isSignUp ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)] : null,
                          ),
                          child: Text('Log In', style: TextStyle(fontWeight: FontWeight.w600, color: !_isSignUp ? Colors.white : AppColors.textSecondary)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSignUp = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isSignUp ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isSignUp ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)] : null,
                          ),
                          child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w600, color: _isSignUp ? Colors.white : AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isSignUp) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('FULL NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    Text('REQUIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('PROFESSIONAL EMAIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  Text('REQUIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  Text('MIN 8 CHARACTERS', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    Text('MUST MATCH', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 14),
                // Trainer Accreditation Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trainer Accreditation Required', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            SizedBox(height: 2),
                            Text('Profiles and fitness certificates are verified by the System Admin (Screen A04) before workout publishing privileges are unlocked.',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      activeColor: AppColors.brandTeal,
                      onChanged: (v) => setState(() => _agreeTerms = v!),
                    ),
                    const Expanded(
                      child: Text('I agree to FitPulse Trainer Terms & Fitness Coaching Guidelines', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: _isSignUp ? 'Register as Trainer →' : 'Log In as Trainer →',
                onPressed: _submitAction,
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR CONTINUE WITH', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              // Real Google Account Sign-In Button
              OutlinedButton.icon(
                onPressed: _loginWithGoogle,
                icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA4335), fontSize: 18)),
                label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().login(email: 'alex.carter@fitpulse.com', role: UserRole.trainer);
                },
                icon: const Icon(Icons.apple, color: Colors.black, size: 20),
                label: const Text('Continue with Apple'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? 'Already registered as a Trainer? Log In' : 'Don\'t have a Trainer account? Sign Up',
                    style: const TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 12),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
