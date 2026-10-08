import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'core/models/user_role.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/history_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/workout_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_shell.dart';
import 'features/advisor/advisor_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/customer/customer_shell.dart';
import 'features/customer/onboarding_screen.dart';
import 'features/customer/profile_setup_screen.dart';
import 'features/customer/splash_screen.dart';
import 'features/trainer/trainer_shell.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    try {
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    } catch (_) {}
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    await SupabaseService.initializeSupabase();
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  StorageService.initializeStorage().catchError((e) {
    debugPrint('StorageService init error: $e');
  });

  if (!kIsWeb) {
    NotificationService().init().catchError((e) {
      debugPrint('NotificationService init error: $e');
    });
  }

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
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final role = auth.currentUser?.role ?? UserRole.customer;
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
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
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String? _lastUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final currentId = auth.currentUser?.id;
    if (_lastUserId != null && _lastUserId != currentId) {
      rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    _lastUserId = currentId;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // 1. Loading state
    if (auth.isLoading) {
      return const SplashScreen();
    }

    // 2. Logged Out state
    if (!auth.isLoggedIn) {
      return const UnauthFlow();
    }

    // 3. User null safety check
    final user = auth.currentUser;
    if (user == null) {
      return const UnauthFlow();
    }

    switch (user.role) {
      case UserRole.customer:
        if (!user.isProfileCompleted) {
          return const ProfileSetupScreen();
        }
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

  @override
  State<UnauthFlow> createState() => _UnauthFlowState();
}

class _UnauthFlowState extends State<UnauthFlow> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_showSplash) {
      return const SplashScreen();
    }

    if (!auth.onboardingSeen) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: OnboardingScreen(
          onDone: () async {
            await auth.completeOnboarding();
          },
        ),
      );
    }

    return const Scaffold(
      backgroundColor: Colors.white,
      body: LoginScreen(role: UserRole.customer),
    );
  }
}
