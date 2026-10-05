import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'trainer_settings_screen.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

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
        title: const Text('Trainer Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainerSettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.brandTeal, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(user?.name ?? 'Alex Carter', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: const [
                      _Chip(label: 'Bodyweight', color: AppColors.brandTeal),
                      _Chip(label: 'Mobility', color: AppColors.info),
                      _Chip(label: 'Hypertrophy', color: AppColors.purple),
                      _Chip(label: 'Posture', color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Certified Fitness Trainer & Kinesiologist', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  const Text('• Verified Professional', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 140,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(120, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: AppColors.brandTeal),
                      ),
                      onPressed: () {},
                      child: const Text('Edit Profile ✏', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats Row
            Row(
              children: const [
                Expanded(child: _TrainerStat(value: '14', label: 'Created', icon: Icons.fullscreen, color: AppColors.info)),
                SizedBox(width: 8),
                Expanded(child: _TrainerStat(value: '11', label: 'Active', icon: Icons.check_circle_outline, color: AppColors.success)),
                SizedBox(width: 8),
                Expanded(child: _TrainerStat(value: '3', label: 'Pending QA', icon: Icons.hourglass_top, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 16),
            // About Coach Alex Card
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('About Coach Alex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 6),
                  Text(
                    'Fitness trainer with 5+ years of experience helping beginners achieve their health and fitness goals. Specializes in home workouts, functional mobility, and progressive strength conditioning.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('2 Active', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            _certTile('ACE Certified Personal Trainer', 'American Council on Exercise • Valid thru 2026'),
            const SizedBox(height: 8),
            _certTile('NASM Corrective Exercise Special', 'National Academy of Sports Medicine'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Assigned Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('3 Total', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            _moduleTile('Core Foundations A1', '8 exercises • Week 1-2'),
            const SizedBox(height: 8),
            _moduleTile('Dynamic Mobility Block', '5 exercises • Daily Routine'),
            const SizedBox(height: 8),
            _moduleTile('Upper Body Hypertrophy I', '6 exercises • Week 3-4'),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('Sign Out of FitPulse', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _certTile(String title, String sub) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.verified, color: AppColors.brandTeal, size: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.brandTeal, size: 16),
        ],
      ),
    );
  }

  Widget _moduleTile(String title, String sub) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(width: 40, height: 40, color: Colors.grey.shade200, child: const Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _TrainerStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _TrainerStat({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
