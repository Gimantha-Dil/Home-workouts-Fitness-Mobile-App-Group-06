import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'admin_settings_screen.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _appNameController = TextEditingController(text: 'FitPulse');
  final _supportEmailController = TextEditingController(text: 'support@fitpulse.com');
  final String _timezone = '(GMT+05:30) Sri Lanka Time';

  final bool _allowRegistration = true;
  final bool _requireTrainerApproval = true;
  final bool _requireAdvisorApproval = true;
  final bool _enableNotifications = true;

  @override
  void dispose() {
    _appNameController.dispose();
    _supportEmailController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    try {
      await FirebaseFirestore.instance.collection('appConfig').doc('settings').set({
        'appName': _appNameController.text.trim(),
        'supportEmail': _supportEmailController.text.trim(),
        'timezone': _timezone,
        'allowRegistration': _allowRegistration,
        'requireTrainerApproval': _requireTrainerApproval,
        'requireAdvisorApproval': _requireAdvisorApproval,
        'enableNotifications': _enableNotifications,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System configuration saved & backup snapshot created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save configuration: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('System Configuration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  const Text('Manage global application parameters, platform rules, and operational settings.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PLATFORM BRANDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _appNameController,
                          decoration: const InputDecoration(labelText: 'Application Name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _supportEmailController,
                          decoration: const InputDecoration(labelText: 'Support Contact Email'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: AppColors.brandTeal),
                          ),
                          onPressed: _saveConfig,
                          child: const Text('Backup Now ☁', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
