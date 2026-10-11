import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../auth/role_select_screen.dart';
import 'trainer_shell.dart';
import 'trainer_verification_screen.dart';

class TrainerRegistrationScreen extends StatefulWidget {
  const TrainerRegistrationScreen({super.key});

  @override
  State<TrainerRegistrationScreen> createState() => _TrainerRegistrationScreenState();
}

class _TrainerRegistrationScreenState extends State<TrainerRegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _isSignUp = true;
  bool _loading = false;

  bool get _isEmailValid => _emailController.text.contains('@') && _emailController.text.contains('.');
  bool get _isPasswordValid => _passwordController.text.length >= (_isSignUp ? 8 : 1);
  bool get _isConfirmPasswordValid => _confirmPasswordController.text == _passwordController.text && _confirmPasswordController.text.isNotEmpty;
  bool get _isNameValid => _nameController.text.trim().length >= 2;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.loginWithGoogle();

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showSnack(error);
    } else if (_isSignUp) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TrainerVerificationScreen()),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrainerShell()),
            (route) => false,
      );
    }
  }

  Future<void> _submitAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showSnack('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showSnack('Please enter your password.');
      return;
    }

    if (_isSignUp) {
      if (name.isEmpty) {
        _showSnack('Please enter your full name.');
        return;
      }

      final passRegex = RegExp(r'^(?=.*[0-9]).{8,}$');
      if (!passRegex.hasMatch(password)) {
        _showSnack('Password must be at least 8 characters long and contain at least 1 number.');
        return;
      }

      if (confirmPass != password) {
        _showSnack('Passwords do not match.');
        return;
      }

      if (!_agreeTerms) {
        _showSnack('Please agree to the Trainer Terms & Fitness Coaching Guidelines.');
        return;
      }
    }

    setState(() => _loading = true);
    final authProvider = context.read<AuthProvider>();

    String? error;
    if (_isSignUp) {
      error = await authProvider.signUp(
        name: name,
        email: email,
        password: password,
      );
    } else {
      error = await authProvider.login(
        email: email,
        password: password,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showSnack(error);
    } else if (_isSignUp) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TrainerVerificationScreen()),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrainerShell()),
            (route) => false,
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
            );
          },
        ),
        title: const Row(
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
              const _Badge(text: 'TRAINER CERTIFICATION PORTAL', color: AppColors.brandTeal),
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
                        onTap: _loading ? null : () => setState(() => _isSignUp = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isSignUp ? AppColors.brandTeal : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isSignUp ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)] : null,
                          ),
                          child: Text('Log In', style: TextStyle(fontWeight: FontWeight.w600, color: !_isSignUp ? Colors.white : AppColors.textSecondary)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _loading ? null : () => setState(() => _isSignUp = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isSignUp ? AppColors.brandTeal : Colors.transparent,
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
                  children: [
                    const Text('FULL NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    if (_isNameValid)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 12),
                          SizedBox(width: 4),
                          Text('VALID NAME', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      )
                    else
                      const Text('REQUIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _nameController,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    suffixIcon: _nameController.text.isNotEmpty
                        ? Icon(_isNameValid ? Icons.check_circle : Icons.error_outline,
                            color: _isNameValid ? AppColors.success : AppColors.danger, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PROFESSIONAL EMAIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  if (_isEmailValid)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 12),
                        SizedBox(width: 4),
                        Text('VALID EMAIL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    )
                  else
                    const Text('REQUIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _emailController,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your professional email',
                  prefixIcon: const Icon(Icons.alternate_email),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? Icon(_isEmailValid ? Icons.check_circle : Icons.error_outline,
                          color: _isEmailValid ? AppColors.success : AppColors.danger, size: 18)
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  if (_isSignUp && _isPasswordValid)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 12),
                        SizedBox(width: 4),
                        Text('STRONG PASSWORD', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    )
                  else
                    Text(_isSignUp ? 'MIN 8 CHARACTERS' : 'SECURE', style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_passwordController.text.isNotEmpty)
                        Icon(_isPasswordValid ? Icons.check_circle : Icons.error_outline,
                            color: _isPasswordValid ? AppColors.success : AppColors.danger, size: 18),
                      IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    if (_isConfirmPasswordValid)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 12),
                          SizedBox(width: 4),
                          Text('PASSWORDS MATCH', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      )
                    else
                      const Text('MUST MATCH', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !_loading,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_confirmPasswordController.text.isNotEmpty)
                          Icon(_isConfirmPasswordValid ? Icons.check_circle : Icons.error_outline,
                              color: _isConfirmPasswordValid ? AppColors.success : AppColors.danger, size: 18),
                        IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trainer Accreditation Required', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            SizedBox(height: 2),
                            Text('Profiles and fitness certificates are verified by the System Admin before workout publishing privileges are unlocked.',
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
                      onChanged: _loading ? null : (v) => setState(() => _agreeTerms = v ?? false),
                    ),
                    const Expanded(
                      child: Text('I agree to FitPulse Trainer Terms & Fitness Coaching Guidelines', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                PrimaryButton(
                  label: _isSignUp ? 'Register as Trainer →' : 'Log In as Trainer →',
                  onPressed: _submitAction,
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR CONTINUE WITH', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _loginWithGoogle,
                  icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA4335), fontSize: 18)),
                  label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : () => setState(() => _isSignUp = !_isSignUp),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
