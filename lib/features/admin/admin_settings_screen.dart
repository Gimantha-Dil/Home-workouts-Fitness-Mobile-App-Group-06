import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/screens/notification_center_screen.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_management_screen.dart';
import 'safety_content_management_screen.dart';
import 'system_settings_screen.dart';
import 'trainer_management_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenanceMode = false;
  final String _appearance = 'Light Mode';
  String _locale = 'English (US)';

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }



  void _openLocaleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('System Language & Locale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English (US)', 'Sinhala (සිංහල)', 'Tamil (தமிழ்)'].map((l) {
            return RadioListTile<String>(
              title: Text(l, style: const TextStyle(fontSize: 13)),
              value: l,
              groupValue: _locale,
              activeColor: AppColors.brandTeal,
              onChanged: (v) {
                setState(() => _locale = v!);
                Navigator.of(ctx).pop();
                _showSnack('System locale set to $_locale');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openRolesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('User Roles & RBAC Governance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Superadmin: Full root access, backup & system config', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('• Trainer: Workout publishing, client analytics', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('• Advisor: Medical guidelines, safety content moderation', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('• Customer: Routine tracking, biometrics & goals', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openApiKeysDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Keys & Webhook Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stripe Gateway: sk_live_••••••••9421 [Active]', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
            SizedBox(height: 6),
            Text('Firebase Cloud Messaging: Active • 14ms Latency', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('Health Connect Bridge: Connected • 256-bit AES Key', style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About FitPulse Admin Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FitPulse Admin v1.0.0-PROD (Build 342)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Kinetic Pulse Engine 4.1 Architecture', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('Server Node: Sri Lanka Central / Node-01', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
            Text('Encryption: 256-bit SSL Root Encrypted', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
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
        title: const Row(
          children: [
            Text('Admin Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 6),
            Text('A11 • ROOT CONFIG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Color(0xFFCCFBF1), shape: BoxShape.circle),
            child: const Icon(Icons.verified, size: 14, color: AppColors.brandTeal),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Admin User Card
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.brandTeal.withValues(alpha: 0.12),
                    child: const Icon(Icons.admin_panel_settings, color: AppColors.brandTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user?.name ?? 'System Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                              child: const Text('SUPERUSER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                          ],
                        ),
                        Text(user?.email ?? 'admin@example.com', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const Text('Global Infrastructure & Security Officer', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.tune,
              'System Alerts & Logs',
              'Server telemetry, critical alerts & anomalies',
              AppColors.info,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SystemSettingsScreen())),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: AppColors.warning.withValues(alpha: 0.12), child: const Icon(Icons.build_circle_outlined, color: AppColors.warning, size: 16)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Pause trainee signups & background jobs', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(_maintenanceMode ? 'ON' : 'OFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _maintenanceMode ? AppColors.danger : AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Switch(
                    value: _maintenanceMode,
                    activeThumbColor: AppColors.brandTeal,
                    onChanged: (v) {
                      setState(() => _maintenanceMode = v);
                      _showSnack(v ? 'Maintenance Mode Activated' : 'Maintenance Mode Deactivated');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            _settingTile(
              Icons.language_outlined,
              'System Language & Locale',
              'UTC+05:30 • English (US)',
              AppColors.brandTeal,
              badge: _locale,
              onTap: _openLocaleDialog,
            ),
            const SizedBox(height: 20),
            const Text('PLATFORM & GOVERNANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.security_outlined,
              'User Roles & Permissions',
              'Trainers, Advisors & Customer RBAC rules',
              AppColors.brandTeal,
              onTap: _openRolesDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.verified_user_outlined,
              'Verification Queues',
              'Trainer credentials & advisor board',
              AppColors.warning,
              badge: '3 PENDING',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainerManagementScreen())),
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.health_and_safety_outlined,
              'Advisor Approvals',
              'Healthcare advisor board verification',
              AppColors.purple,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvisorManagementScreen())),
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.shield_outlined,
              'Safety Content Rules',
              'ACSM clinical safety protocols & guidelines',
              AppColors.success,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SafetyContentManagementScreen())),
            ),
            const SizedBox(height: 20),
            const Text('SUPPORT & SYSTEM INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.api_outlined,
              'API Keys & Webhooks',
              'Stripe webhooks, push services & gateway',
              AppColors.info,
              onTap: _openApiKeysDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.info_outline,
              'About FitPulse Platform',
              'Build v1.0.0-PROD • Architecture Schematics',
              AppColors.purple,
              onTap: _openAboutDialog,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: InkWell(
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.power_settings_new, color: AppColors.danger, size: 18),
                    SizedBox(width: 8),
                    Text('Terminate Admin Session', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String sub, Color color, {String? badge, VoidCallback? onTap}) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
