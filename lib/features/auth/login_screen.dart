import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/common_widgets.dart';
import '../admin/admin_shell.dart';
import '../advisor/advisor_registration_screen.dart';
import '../advisor/advisor_shell.dart';
import '../advisor/advisor_verification_screen.dart';
import '../customer/customer_shell.dart';
import '../customer/profile_setup_screen.dart';
import '../trainer/trainer_registration_screen.dart';
import '../trainer/trainer_shell.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;
  late bool _isSignUp;
  bool _agreeTerms = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Admin portal NEVER allows sign up - only log in!
    _isSignUp = widget.role == UserRole.admin ? false : true;
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

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final confirmPass = _confirmPasswordController.text;

    if (!Validators.isValidEmail(email)) {
      _showSnack('Please enter a valid email address.');
      return false;
    }

    if (password.isEmpty) {
      _showSnack('Please enter your password.');
      return false;
    }

    if (_isSignUp) {
      if (name.isEmpty) {
        _showSnack('Please enter your full name.');
        return false;
      }

      if (!Validators.isValidPassword(password)) {
        _showSnack('Password must be at least 8 characters long and contain at least 1 number.');
        return false;
      }

      if (!Validators.passwordsMatch(password, confirmPass)) {
        _showSnack('Passwords do not match.');
        return false;
      }

      if (!_agreeTerms) {
        _showSnack('Please agree to the Terms of Service & Privacy Policy.');
        return false;
      }
    }

    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validateInputs()) return;

    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
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

    // Login එකේදී මොකක් හරි error එකක් ආවා නම්
    if (error != null) {
      setState(() => _loading = false);
      _showSnack(error);
      return;
    }

    // Role එක Verify කිරීම
    final user = authProvider.currentUser;
    if (widget.role != UserRole.customer) {
      if (user == null || user.role != widget.role) {
        await authProvider.logout();
        if (!mounted) return;
        setState(() => _loading = false);
        _showSnack('This account is not authorized for this portal.');
        return;
      }
    }

    setState(() => _loading = false);

    if (widget.role == UserRole.admin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminShell()),
        (route) => false,
      );
    } else if (widget.role == UserRole.trainer) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrainerShell()),
        (route) => false,
      );
    } else if (widget.role == UserRole.advisor) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdvisorShell()),
        (route) => false,
      );
    } else {
      if (_isSignUp) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerShell()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.loginWithGoogle();

    if (!mounted) return;

    if (error != null) {
      setState(() => _loading = false);
      _showSnack(error);
      return;
    }

    final user = authProvider.currentUser;
    if (widget.role != UserRole.customer) {
      if (user == null || user.role != widget.role) {
        await authProvider.logout();
        if (!mounted) return;
        setState(() => _loading = false);
        _showSnack('This account is not authorized for this portal.');
        return;
      }
    }

    setState(() => _loading = false);

    if (widget.role == UserRole.admin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminShell()),
        (route) => false,
      );
    } else if (widget.role == UserRole.trainer) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrainerShell()),
        (route) => false,
      );
    } else if (widget.role == UserRole.advisor) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdvisorShell()),
        (route) => false,
      );
    } else {
      if (user != null && !user.isProfileCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerShell()),
          (route) => false,
        );
      }
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
        leading: widget.role != UserRole.customer || Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.brandTeal),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                    );
                  }
                },
              )
            : null,
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
              Text(
                widget.role == UserRole.admin
                    ? 'Admin Portal'
                    : widget.role == UserRole.trainer
                        ? 'Trainer Portal'
                        : widget.role == UserRole.advisor
                            ? 'Advisor Portal'
                            : _isSignUp ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                _isSignUp ? 'Sign up to start your personalized fitness journey.' : 'Log in to continue your fitness journey.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),

              // "Are you Professional? →" Banner Button (Matching Image 1 mockup)
              if (widget.role == UserRole.customer) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF0284C7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Are you Professional?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 20),

              // Tab Toggle (Log In / Sign Up) - Hidden for Admin!
              if (widget.role != UserRole.admin) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                              border: !_isSignUp ? Border.all(color: AppColors.brandTeal, width: 1.5) : null,
                            ),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_isSignUp ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
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
                              border: _isSignUp ? Border.all(color: AppColors.brandTeal, width: 1.5) : null,
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isSignUp ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Full Name (Only shown on Sign Up)
              if (_isSignUp) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('FULL NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    Text('REQUIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email Address
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EMAIL ADDRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  Text('REQUIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  Text(_isSignUp ? 'MIN. 8 CHARS' : '', style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: _isSignUp ? 'At least 8 characters' : 'Enter your password',
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
                    Icon(Icons.info_outline, size: 12, color: AppColors.brandTeal),
                    SizedBox(width: 4),
                    Text('Must be 8+ characters with at least 1 number', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),

              // Confirm Password (Only shown on Sign Up)
              if (_isSignUp) ...[
                const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      activeColor: primary,
                      onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to FitPulse Terms of Service & Privacy Policy',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Forgot Password link (Only on Log In)
              if (!_isSignUp) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                    ),
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Main Action Button
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  label: _isSignUp ? 'Create Account →' : 'Log In →',
                  onPressed: _handleSubmit,
                ),

              const SizedBox(height: 16),

              // Google Sign In Button
              if (!_isSignUp || widget.role == UserRole.customer) ...[
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
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  onPressed: _loading ? null : _loginWithGoogle,
                  icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA4335), fontSize: 18)),
                  label: const Text('Continue with Google', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
