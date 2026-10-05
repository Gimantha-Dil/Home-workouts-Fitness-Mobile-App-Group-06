import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/models/user_role.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/customer/splash_screen.dart';
import 'features/customer/onboarding_screen.dart';
import 'features/customer/customer_shell.dart';
import 'features/trainer/trainer_shell.dart';
import 'features/advisor/advisor_shell.dart';
import 'features/admin/admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initializeSupabase();
  runApp(const FitPulseApp());
}

class FitPulseApp extends StatelessWidget {
  const FitPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final role = auth.currentUser?.role ?? UserRole.customer;
          final userKey = auth.currentUser?.id ?? 'logged_out';
          return MaterialApp(
            key: ValueKey(userKey),
            title: 'FitPulse',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeForRole(role),
            home: const AppRoot(),
          );
        },
      ),
    );
  }
}

/// Decides which screen to show based on auth + onboarding state.
/// - Not logged in -> SplashScreen -> OnboardingScreen -> LoginScreen
/// - Logged in as Customer -> CustomerShell
/// - Logged in as Trainer/Advisor/Admin -> their respective shell
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const UnauthFlow();
    }

    switch (auth.currentUser!.role) {
      case UserRole.customer:
        return const CustomerShell();
      case UserRole.trainer:
        return const TrainerShell();
      case UserRole.advisor:
        return const AdvisorShell();
      case UserRole.admin:
        return const AdminShell();
    }
  }
}

class UnauthFlow extends StatefulWidget {
  const UnauthFlow({super.key});

  static bool splashAlreadyShown = false;

  @override
  State<UnauthFlow> createState() => _UnauthFlowState();
}

class _UnauthFlowState extends State<UnauthFlow> {
  late bool _showSplash;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _showSplash = !UnauthFlow.splashAlreadyShown;
    if (_showSplash) {
      UnauthFlow.splashAlreadyShown = true;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _showSplash = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }
    if (!_onboardingCompleted) {
      return OnboardingScreen(
        onDone: () => setState(() => _onboardingCompleted = true),
      );
    }
    return const LoginScreen(role: UserRole.customer);
  }
}
