import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class TrainerSettingsScreen extends StatefulWidget {
  const TrainerSettingsScreen({super.key});

  @override
  State<TrainerSettingsScreen> createState() => _TrainerSettingsScreenState();
}

class _TrainerSettingsScreenState extends State<TrainerSettingsScreen> {
  bool _coachingAvailable = true;
  String _appearance = 'Light';
  String _language = 'English';

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trainer Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('• Client Check-in Alerts: Enabled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('• Moderation & QA Notices: Enabled', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('• Direct Trainee Messages: Sound ON', style: TextStyle(fontSize: 12, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
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

  void _openAppearanceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Builder Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Light', 'Dark', 'Builder Wireframe'].map((a) {
            return RadioListTile<String>(
              title: Text(a, style: const TextStyle(fontSize: 13)),
              value: a,
              groupValue: _appearance,
              activeColor: AppColors.brandTeal,
              onChanged: (v) {
                setState(() => _appearance = v!);
                Navigator.of(ctx).pop();
                _showSnack('Appearance changed to $_appearance');
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
          children: ['English', 'Sinhala (සිංහල)', 'Tamil (தமிழ்)'].map((l) {
            return RadioListTile<String>(
              title: Text(l, style: const TextStyle(fontSize: 13)),
              value: l,
              groupValue: _language,
              activeColor: AppColors.brandTeal,
              onChanged: (v) {
                setState(() => _language = v!);
                Navigator.of(ctx).pop();
                _showSnack('Language set to $_language');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openCertsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Certifications & Accreditation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• ACE Certified Personal Trainer (#89421) ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
            SizedBox(height: 6),
            Text('• NASM Corrective Exercise Specialist ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.info)),
            SizedBox(height: 8),
            Text('Verification Status: Active Coaching Privileges', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
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

  void _openDefaultsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout Publishing Defaults', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Default Rest Interval: 60 seconds', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Default Rep Target: 10 reps / 3 sets', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('Video Resolution: 1080p 60 FPS Mobile Stream', style: TextStyle(fontSize: 12, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Save Defaults', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trainee Data & GDPR Safeguards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: const Text(
          'All trainee heart rate logs and workout analytics are strictly anonymized and GDPR compliant. Trainers cannot export personal identity telemetry without consent.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understand', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openHelpDeskSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trainer Help Desk & Escalation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Direct support line to System Admin & Clinical Reviewers.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.verified, color: AppColors.brandTeal),
              title: Text('SLA 4-Hour Moderation Guarantee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Text('Submitted workouts are reviewed within 4 hours by healthcare advisors.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Contact Admin Escalation →',
              onPressed: () {
                Navigator.of(ctx).pop();
                _showSnack('Escalation ticket submitted to Admin!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About FitPulse Trainer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('FitPulse Trainer Studio v1.0.4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Builder 2.0 • Dynamic Pacing & Transcoding Engine', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('Coaching Terms & Conditions Agreed', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
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
        title: Row(
          children: const [
            Text('Trainer Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 6),
            Text('T13 // SYSTEM CONFIG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, size: 20), onPressed: _openNotificationsDialog),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Card
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user?.name ?? 'Alex Carter', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                              child: const Text('ACE VERIFIED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                          ],
                        ),
                        Text(user?.email ?? 'alex.carter@fitpulse.trainer', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const Text('Strength & Conditioning Coach', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.notifications_outlined,
              'Notifications',
              'Client check-ins, routine alerts & reviews',
              AppColors.warning,
              onTap: _openNotificationsDialog,
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: AppColors.brandTeal.withOpacity(0.12), child: const Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Coaching Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Accepting new trainee requests', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                    child: Text(_coachingAvailable ? '• Active' : 'Offline', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _coachingAvailable,
                    activeColor: AppColors.brandTeal,
                    onChanged: (v) {
                      setState(() => _coachingAvailable = v);
                      _showSnack(v ? 'Coaching status: Active' : 'Coaching status: Offline');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.color_lens_outlined,
              'Appearance',
              'Theme & visual workout builder view',
              AppColors.purple,
              badge: _appearance,
              onTap: _openAppearanceDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.language_outlined,
              'Language',
              'System terminology & exercise cues',
              AppColors.brandTeal,
              badge: _language,
              onTap: _openLanguageDialog,
            ),
            const SizedBox(height: 20),
            const Text('WORKOUT & COACHING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.verified_user_outlined,
              'Certifications & Credentials',
              'ACE-CPT #89421, NASM Strength Spec.',
              AppColors.brandTeal,
              onTap: _openCertsDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.publish_outlined,
              'Workout Publishing Defaults',
              'Default rest intervals, reps & video quality',
              AppColors.info,
              onTap: _openDefaultsDialog,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.shield_outlined,
              'Trainee Data & Privacy',
              'GDPR fitness data safeguards, logged analytics',
              AppColors.purple,
              onTap: _openPrivacyDialog,
            ),
            const SizedBox(height: 20),
            const Text('SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _settingTile(
              Icons.help_outline,
              'Trainer Help Desk',
              'Admin escalation & coaching guidelines',
              AppColors.warning,
              onTap: _openHelpDeskSheet,
            ),
            const SizedBox(height: 8),
            _settingTile(
              Icons.info_outline,
              'About FitPulse Trainer',
              'Version 1.0.4 • Coaching Terms & Conditions',
              AppColors.info,
              onTap: _openAboutDialog,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: InkWell(
                onTap: () => context.read<AuthProvider>().logout(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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

  Widget _settingTile(IconData icon, String title, String sub, Color color, {String? badge, VoidCallback? onTap}) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 16)),
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
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
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
