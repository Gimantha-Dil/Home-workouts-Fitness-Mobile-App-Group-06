import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../customer/profile_setup_screen.dart';
import 'reset_password_screen.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;

  const LoginScreen({
    super.key,
    this.role = UserRole.customer,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp && !_agreeTerms) {
      _showSnack('Please agree to the Terms of Service & Privacy Policy.');
      return;
    }

    setState(() => _loading = true);
    final authProvider = context.read<AuthProvider>();

    String? error;
    if (_isSignUp) {
      error = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      error = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: widget.role,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showSnack(error);
    } else {
      if (_isSignUp && widget.role == UserRole.customer) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
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
        title: Row(
          children: [
            const AppLogoIcon(size: 26),
            const SizedBox(width: 8),
            Text(
              'FitPulse',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Sign up to start your personalized fitness journey.'
                      : 'Log in to continue tracking your workouts.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // ARE YOU PROFESSIONAL? BANNER
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF0284C7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Are you Professional?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (widget.role != UserRole.admin) ...[
                  const SizedBox(height: 16),

                  // TAB TOGGLE (Log In / Sign Up)
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
                                color: !_isSignUp ? primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Log In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: !_isSignUp ? Colors.white : AppColors.textSecondary,
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
                                color: _isSignUp ? primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isSignUp ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                if (_isSignUp) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('FULL NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      if (_isNameValid)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success, size: 12),
                            SizedBox(width: 4),
                            Text('VALID NAME', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        )
                      else
                        const Text('REQUIRED', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name' : null,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
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
                    const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    if (_isEmailValid)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 12),
                          SizedBox(width: 4),
                          Text('VALID EMAIL', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      const Text('REQUIRED', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.alternate_email, size: 20),
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
                    const Text('PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    if (_isSignUp && _isPasswordValid)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 12),
                          SizedBox(width: 4),
                          Text('STRONG PASSWORD', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      Text(
                        _isSignUp ? 'MIN. 8 CHARS' : 'SECURE',
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your password';
                    if (_isSignUp && v.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_passwordController.text.isNotEmpty)
                          Icon(_isPasswordValid ? Icons.check_circle : Icons.error_outline,
                              color: _isPasswordValid ? AppColors.success : AppColors.danger, size: 18),
                        IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_isSignUp) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_isPasswordValid ? Icons.check_circle : Icons.info_outline, size: 12, color: _isPasswordValid ? AppColors.success : AppColors.brandTeal),
                      const SizedBox(width: 4),
                      Text(
                        _isPasswordValid ? 'Password criteria met' : 'Must be 8+ characters',
                        style: TextStyle(fontSize: 10, color: _isPasswordValid ? AppColors.success : AppColors.textSecondary, fontWeight: _isPasswordValid ? FontWeight.bold : FontWeight.normal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      if (_isConfirmPasswordValid)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success, size: 12),
                            SizedBox(width: 4),
                            Text('PASSWORDS MATCH', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_confirmPasswordController.text.isNotEmpty)
                            Icon(_isConfirmPasswordValid ? Icons.check_circle : Icons.error_outline,
                                color: _isConfirmPasswordValid ? AppColors.success : AppColors.danger, size: 18),
                          IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: primary,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      ),
                      const Expanded(
                        child: Text('I agree to FitPulse Terms of Service & Privacy Policy', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                      ),
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.brandTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.brandTeal))
                    : PrimaryButton(
                        label: _isSignUp ? 'Create Account →' : 'Sign In →',
                        onPressed: _submitForm,
                      ),

                const SizedBox(height: 20),

                // OR CONTINUE WITH
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _loginWithGoogle,
                  icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  label: const Text('Sign in with Google', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
