import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  int _tab = 0;
  final _appNameController = TextEditingController(text: 'FitPulse');
  final _supportEmailController = TextEditingController(text: 'support@fitpulse.com');
  String _timezone = '(GMT+05:30) Sri Lanka Time';

  bool _allowRegistration = true;
  bool _requireTrainerApproval = true;
  bool _requireAdvisorApproval = true;
  bool _enableNotifications = true;

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
        title: Row(
          children: const [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('System Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _Badge(text: '• Production', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Configure system preferences and application settings.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  // Tabs
                  Row(
                    children: [
                      Expanded(child: _tabBtn('General', 0)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Notifications', 1)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Security', 2)),
                      const SizedBox(width: 6),
                      Expanded(child: _tabBtn('Appearance', 3)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // General Settings Form Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('General Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Text('Core tenant identity and contact', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 14),
                        const Text('APPLICATION NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _appNameController,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        ),
                        const SizedBox(height: 12),
                        const Text('SUPPORT EMAIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _supportEmailController,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        ),
                        const SizedBox(height: 12),
                        const Text('TIMEZONE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: _timezone,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                          items: const ['(GMT+05:30) Sri Lanka Time', '(GMT+00:00) UTC', '(GMT-05:00) EST']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 11))))
                              .toList(),
                          onChanged: (v) => setState(() => _timezone = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // System Preferences Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('System Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Text('User onboarding & alert policies', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        _switchRow('Allow New User Registration', 'Permits public member signup', _allowRegistration, (v) => setState(() => _allowRegistration = v)),
                        const Divider(height: 16),
                        _switchRow('Require Trainer Approval', 'Manual verification of trainers', _requireTrainerApproval, (v) => setState(() => _requireTrainerApproval = v)),
                        const Divider(height: 16),
                        _switchRow('Require Advisor Approval', 'Admin check for nutritionists/MDs', _requireAdvisorApproval, (v) => setState(() => _requireAdvisorApproval = v)),
                        const Divider(height: 16),
                        _switchRow('Enable System Notifications', 'Push global maintenance notices', _enableNotifications, (v) => setState(() => _enableNotifications = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Maintenance & Status Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Maintenance & Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            _Badge(text: '• Healthy', color: AppColors.success),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Last Backup: Apr 28, 2026', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text('System Version: v1.0.0', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: AppColors.brandTeal),
                          ),
                          onPressed: () {},
                          child: const Text('Backup Now ☁', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: 'Save Changes ✓',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(String title, String sub, bool val, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: val,
          activeColor: AppColors.brandTeal,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
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
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
