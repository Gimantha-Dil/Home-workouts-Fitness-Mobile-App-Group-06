import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../advisor/advisor_verification_screen.dart';
import '../trainer/trainer_verification_screen.dart';
import 'reset_password_screen.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController(text: 'Nethmi Tharuka');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;
  late bool _isSignUp;
  bool _agreeTerms = true;

  @override
  void initState() {
    super.initState();
    // Admin portal NEVER allows sign up - only log in!
    _isSignUp = widget.role == UserRole.admin ? false : true;
  }

  String get _title {
    if (_isSignUp) return 'Create Account';
    switch (widget.role) {
      case UserRole.customer:
        return 'FitPulse';
      case UserRole.trainer:
        return 'Trainer Login';
      case UserRole.advisor:
        return 'Healthcare Advisor Portal';
      case UserRole.admin:
        return 'FitPulse Admin Portal';
    }
  }

  String get _subtitle {
    if (_isSignUp) return 'Sign up to start your personalized fitness journey.';
    switch (widget.role) {
      case UserRole.customer:
        return 'Sign in to continue your beginner streak';
      case UserRole.trainer:
        return 'Access your trainer dashboard';
      case UserRole.advisor:
        return 'Secure access for healthcare professionals';
      case UserRole.admin:
        return 'Sign in to manage the FitPulse system';
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  void _login({String? email, UserRole? role}) {
    if (_isSignUp && email == null) {
      if (widget.role == UserRole.advisor) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdvisorVerificationScreen()),
        );
        return;
      } else if (widget.role == UserRole.trainer) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TrainerVerificationScreen()),
        );
        return;
      }
    }

    final targetRole = role ?? widget.role;
    final inputEmail = _emailController.text.trim();
    final inputPassword = _passwordController.text.trim();

    if (email == null && (inputEmail.isEmpty || inputPassword.isEmpty)) {
      _showSnack('Please enter a valid email address and password.');
      return;
    }

    final resolvedEmail = email ?? inputEmail;
    context.read<AuthProvider>().login(
      email: resolvedEmail,
      role: targetRole,
    );
  }

  void _loginWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final googleUser = await GoogleAuthService.handleGoogleSignIn(
      context: context,
      role: widget.role,
    );
    if (googleUser != null && mounted) {
      authProvider.login(
        email: googleUser.email,
        name: googleUser.name,
        role: googleUser.role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primaryForRole(widget.role);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brandTeal),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (widget.role != UserRole.customer) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
              );
            }
          },
        ),
        title: Row(
          children: const [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 24),
            SizedBox(width: 6),
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
              Text(_title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              // Pro Banner ("Are you Professional? ->") - Navigates to RoleSelectScreen
              if (_isSignUp && widget.role == UserRole.customer) ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Are you Professional?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Tab Bar [ Log In | Sign Up ] - Only for Customer
              if (widget.role == UserRole.customer) ...[
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
                              color: !_isSignUp ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isSignUp ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)] : null,
                            ),
                            child: Text('Log In',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: !_isSignUp ? AppColors.textPrimary : AppColors.textSecondary)),
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
                              color: _isSignUp ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isSignUp ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)] : null,
                            ),
                            child: Text('Sign Up',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _isSignUp ? AppColors.textPrimary : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Inputs
              if (_isSignUp) ...[
                const Text('FULL NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nethmi Tharuka',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: _isSignUp ? 'nethmi1@gmail.com' : 'Email or Phone Number',
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 14),
              const Text('PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: _isSignUp ? 'At least 8 characters' : 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text('Must be 8+ characters with at least 1 number', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      activeColor: primary,
                      onChanged: (v) => setState(() => _agreeTerms = v!),
                    ),
                    const Expanded(
                      child: Text('I agree to FitPulse Terms of Service & Privacy Policy', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                    ),
                    child: const Text('Forgot password?', style: TextStyle(fontSize: 12, color: AppColors.brandTeal)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: _isSignUp ? 'Create Account →' : 'Log In →',
                onPressed: () => _login(),
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
                onPressed: () => _login(email: 'user@icloud.com'),
                icon: const Icon(Icons.apple, color: Colors.black, size: 20),
                label: const Text('Continue with Apple'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
              if (widget.role != UserRole.admin) ...[
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Already have an account? Log In' : 'Don\'t have an account? Sign Up',
                      style: const TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
