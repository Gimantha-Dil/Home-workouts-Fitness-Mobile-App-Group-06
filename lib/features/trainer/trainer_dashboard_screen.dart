import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_workout_screen.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

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
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Good morning, Alex!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Studio Overview • 42 Athletes Online', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hero Create Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F3D3A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateWorkoutScreen())),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.add, color: Colors.white, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('CREATE NEW WORKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Builder 2.0 • Multi-step exercise flow', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Stat Cards Row
            Row(
              children: const [
                Expanded(child: _TrainerStatBox(value: '12', label: 'Total Built', tag: '+2 mo', icon: Icons.fitness_center, color: AppColors.brandTeal)),
                SizedBox(width: 8),
                Expanded(child: _TrainerStatBox(value: '9', label: 'Live Catalog', tag: '98% ★', icon: Icons.published_with_changes, color: AppColors.success)),
                SizedBox(width: 8),
                Expanded(child: _TrainerStatBox(value: '3', label: 'Reviewing', tag: 'In QA', icon: Icons.pending_actions, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 16),
            // Catalog Live Rate Card
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Catalog Live Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('75%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.brandTeal)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('75% of your workout programs are published', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(value: 0.75, minHeight: 6, backgroundColor: Color(0xFFE5E7EB), valueColor: AlwaysStoppedAnimation(AppColors.brandTeal)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('• 9 Published', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      Text('• 3 In QA', style: TextStyle(fontSize: 9, color: AppColors.warning, fontWeight: FontWeight.bold)),
                      Text('• 2 Drafts', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // FastTrack Review SLA Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
              child: Row(
                children: const [
                  Icon(Icons.bolt, color: AppColors.brandTeal, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FitPulse FastTrack Review • SLA: 4h', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        SizedBox(height: 2),
                        Text('Workouts submitted for moderation are clinically reviewed & verified within 4 hours.', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('View All ↗', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            _activityTile('Beginner Full Body', 'Level: Beginner • 12 exercises • 30 min • Edited 2 hours ago', 'DRAFT', AppColors.warning, 'Continue'),
            const SizedBox(height: 8),
            _activityTile('Upper Body Strength', 'Level: Intermediate • 10 exercises • 35 min • 148 athlete completions', 'PUBLISHED', AppColors.success, 'Metrics'),
            const SizedBox(height: 8),
            _activityTile('HIIT Cardio Interval', 'Level: Intermediate • 8 exercises • 25 min • Submitted yesterday at 4:30 PM', 'UNDER REVIEW', AppColors.info, 'Preview'),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(String title, String sub, String status, Color color, String btnText) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(width: 44, height: 44, color: Colors.grey.shade200, child: const Icon(Icons.fitness_center, color: AppColors.brandTeal, size: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    _Badge(text: status, color: color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandTeal,
              minimumSize: const Size(60, 28),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: Text(btnText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TrainerStatBox extends StatelessWidget {
  final String value;
  final String label;
  final String tag;
  final IconData icon;
  final Color color;

  const _TrainerStatBox({required this.value, required this.label, required this.tag, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          Text(tag, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
