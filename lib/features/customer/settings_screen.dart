import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/mock_data.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'customer_shell.dart';
import 'reminders_screen.dart';
import 'safety_guidance_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _faceId = true;
  String _units = 'Metric (kg, cm)';
  String _language = 'English (US)';
  bool _appleHealthSync = true;
  bool _googleFitSync = true;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openUnitsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Units of Measure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Metric (kg, cm)', 'Imperial (lbs, ft)'].map((unit) {
            return RadioListTile<String>(
              title: Text(unit, style: const TextStyle(fontSize: 13)),
              value: unit,
              groupValue: _units,
              activeColor: AppColors.brandTeal,
              onChanged: (v) {
                setState(() => _units = v!);
                Navigator.of(ctx).pop();
                _showSnack('Units changed to $_units');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ('English (US)', '🇺🇸'),
            ('Sinhala (සිංහල)', '🇱🇰'),
            ('Tamil (தமிழ்)', '🇮🇳'),
            ('Spanish (Español)', '🇪🇸'),
          ].map((item) {
            return RadioListTile<String>(
              title: Text('${item.$2}  ${item.$1}', style: const TextStyle(fontSize: 13)),
              value: item.$1,
              groupValue: _language,
              activeColor: AppColors.brandTeal,
              onChanged: (v) {
                setState(() => _language = v!);
                Navigator.of(ctx).pop();
                _showSnack('Language updated to $_language');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openHealthSharingSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Health Data Sharing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Connect your fitness sensors & native health apps', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Apple Health Sync', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Active heart rate & calorie burn telemetry', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                value: _appleHealthSync,
                activeThumbColor: AppColors.brandTeal,
                onChanged: (v) {
                  setSheetState(() => _appleHealthSync = v);
                  setState(() => _appleHealthSync = v);
                },
              ),
              SwitchListTile(
                title: const Text('Google Fit & Health Connect', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Daily step count & active minutes tracking', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                value: _googleFitSync,
                activeThumbColor: AppColors.brandTeal,
                onChanged: (v) {
                  setSheetState(() => _googleFitSync = v);
                  setState(() => _googleFitSync = v);
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Save Preferences',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showSnack('Health data sync settings saved!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('HIPAA Privacy & Data Safeguards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const SingleChildScrollView(
          child: Text(
            'FitPulse is strictly HIPAA compliant and employs end-to-end 256-bit AES encryption for all user biometric and health data.\n\n'
            '1. Data Minimization: We only collect metrics required for exertion calculation.\n'
            '2. Third-Party Sharing: Your health data is never sold or shared with advertisers.\n'
            '3. Control: You can revoke health app sync permissions at any time.',
            style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('I Understand', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openFaqSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help Center & FAQs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Common questions about workouts, metrics & safety', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ExpansionTile(
                    title: Text('How does FitPulse calculate calorie burn?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Calorie burn is calculated using ACSM physiological formulas based on your body weight, session intensity, and duration.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('What should I do if I feel dizzy during a workout?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Stop exercising immediately, sit or lie down in a cool space, sip water, and refer to the Safety Guidance section.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('Can I download workouts for offline use?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Yes! Pro members can save up to 5 workout routines offline for uninterrupted training anywhere.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSupportSheet() {
    final msgController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: Color(0xFFFEF3C7), child: Icon(Icons.support_agent, color: AppColors.warning, size: 16)),
                SizedBox(width: 8),
                Text('Contact Trainer Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Spacer(),
                Text('24/7 Priority', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Send a direct message to certified fitness coaches.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: msgController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your message or question here...',
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Send Message →',
              onPressed: () {
                Navigator.of(ctx).pop();
                _showSnack('Support ticket created! A trainer will respond shortly.');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openEngineInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kinetic Pulse Engine Architecture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: v2.4.0 (Build 342)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            Text('Telemetry Protocol: Real-time Biometric Stream v4.12', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('Server Node: Asia-South1 (Colombo Edge)', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
            Text('Latency: 14 ms • 100% Operational', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
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
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CustomerShell()),
              );
            }
          },
        ),
        title: const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openFaqSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Header Card
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: ClipOval(
                      child: AppNetworkImage(
                        url: user?.profilePhotoUrl,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user?.name ?? 'FitPulse User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, size: 14, color: AppColors.brandTeal),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                              child: const Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                          ],
                        ),
                        Text(user?.email ?? 'user@example.com', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                    child: const Text('• Sync Active', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingRow(
              Icons.notifications_outlined,
              'Notifications',
              'Push alerts, audio cues, streak',
              AppColors.warning,
              badge: 'Sound ON',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RemindersScreen())),
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.square_foot_outlined,
              'Units of Measure',
              'Body weight, distance, load',
              AppColors.info,
              badge: _units,
              onTap: _openUnitsDialog,
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.language_outlined,
              'Language',
              'Voice cues & advisory terminology',
              AppColors.brandTeal,
              badge: _language,
              onTap: _openLanguageDialog,
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PRIVACY & SECURITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Icon(Icons.shield_outlined, size: 14, color: AppColors.brandTeal),
              ],
            ),
            const SizedBox(height: 10),
            _settingRow(
              Icons.favorite_outline,
              'Health Data Sharing',
              'Apple Health & Health Connect',
              AppColors.danger,
              badge: '• Connected',
              onTap: _openHealthSharingSheet,
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: AppColors.brandTeal.withValues(alpha: 0.12), child: const Icon(Icons.fingerprint, color: AppColors.brandTeal, size: 16)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biometric Face ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Require biometric scan to unlock', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _faceId,
                    activeThumbColor: AppColors.brandTeal,
                    onChanged: (v) {
                      setState(() => _faceId = v);
                      _showSnack(v ? 'Biometric Face ID Enabled' : 'Biometric Face ID Disabled');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.description_outlined,
              'Privacy Policy & Terms',
              'HIPAA compliant health safeguards',
              AppColors.info,
              badge: 'HIPAA',
              onTap: _openPrivacyPolicyDialog,
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CLINICAL GOVERNANCE & SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('Accredited', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            _settingRow(
              Icons.verified_user_outlined,
              'Safety Guidelines & Disclaimers',
              'Certified healthcare advisor guidance',
              AppColors.brandTeal,
              showExternal: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SafetyGuidanceScreen(workout: MockData.workouts.first))),
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.help_outline,
              'Help Center & FAQs',
              'Tutorials, heart rate zones, sensor pairings',
              AppColors.info,
              onTap: _openFaqSheet,
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.support_agent_outlined,
              'Contact Trainer Support',
              'Live chat with certified exercis',
              AppColors.warning,
              badge: '24/7 Priority',
              onTap: _openSupportSheet,
            ),
            const SizedBox(height: 8),
            _settingRow(
              Icons.info_outline,
              'Engine Architecture',
              'Kinetic Pulse Engine 4.1',
              AppColors.purple,
              badge: 'FitPulse v2.4.0 (Build 342)',
              onTap: _openEngineInfoDialog,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: InkWell(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final auth = context.read<AuthProvider>();
                  await auth.logout();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppRoot()),
                    (route) => false,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.danger, size: 18),
                    SizedBox(width: 8),
                    Text('Log Out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(IconData icon, String title, String sub, Color color, {String? badge, bool showExternal = false, VoidCallback? onTap}) {
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
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          Icon(showExternal ? Icons.open_in_new : Icons.chevron_right, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
