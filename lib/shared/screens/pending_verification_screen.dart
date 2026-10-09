import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Account Verification Pending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.danger),
            onPressed: () => context.read<AuthProvider>().logout(),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, size: 48, color: AppColors.warning),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome, ${user?.name ?? 'Professional'}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your credentials and verification proof have been submitted to the System Administrator.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: AppColors.info),
                          SizedBox(width: 8),
                          Text('Access Restricted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Until the Admin reviews and approves your account, you cannot access the app features, dashboard, or data creation tools. You will receive full access as soon as approval is granted.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'LOG OUT',
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
