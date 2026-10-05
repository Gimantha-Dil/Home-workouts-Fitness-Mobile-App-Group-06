import 'package:flutter/material.dart';
import '../models/user_role.dart';

class AppColors {
  // Unified FitPulse brand teal, used across every role — matches the
  // production Hi-Fi mockups where all portals (customer, trainer,
  // advisor, admin) share the same teal identity.
  static const brandTeal = Color(0xFF0D9488);
  static const brandTealLight = Color(0xFF14B8A6);
  static const brandTealDark = Color(0xFF0F3D3A);

  static const customerPrimary = brandTeal;
  static const advisorPrimary = brandTeal;
  static const adminPrimary = brandTeal;
  static const trainerPrimary = brandTeal;

  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFEDF0F2);

  static const splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F3D3A), Color(0xFF0D9488)],
  );
}

class AppTheme {
  static Color primaryForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.customerPrimary;
      case UserRole.trainer:
        return AppColors.trainerPrimary;
      case UserRole.advisor:
        return AppColors.advisorPrimary;
      case UserRole.admin:
        return AppColors.adminPrimary;
    }
  }

  static ThemeData themeForRole(UserRole role) {
    final primary = primaryForRole(role);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      // Hi-Fi mockups use clean white app bars with dark titles and small
      // teal/colored accents — not a solid brand-colored bar — across every
      // inner screen (splash/login/role-select build their own dark header).
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
