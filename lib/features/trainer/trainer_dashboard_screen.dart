import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_workout_screen.dart';
import 'edit_workout_screen.dart';
import 'workout_management_screen.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              child: ClipOval(
                child: AppNetworkImage(
                  url: user?.profilePhotoUrl,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, ${user?.name.split(' ').first ?? 'Trainer'}!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Text('Studio Overview • Live Supabase DB', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Workout>>(
          stream: SupabaseService.streamWorkoutsFromSupabase(),
          builder: (context, snapshot) {
            final docs = snapshot.data ?? [];

            final totalBuilt = docs.length;
            final liveCatalog = docs.where((w) => w.isPublished).length;
            final inReview = docs.where((w) => !w.isPublished).length;

            return ListView(
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
                    child: const Row(
                      children: [
                        CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.add, color: Colors.white, size: 22)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CREATE NEW WORKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Builder 2.0 • Multi-step exercise flow', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stat Cards Row
                Row(
                  children: [
                    Expanded(child: _TrainerStatBox(value: '$totalBuilt', label: 'Total Built', tag: 'Supabase DB', icon: Icons.fitness_center, color: AppColors.brandTeal)),
                    const SizedBox(width: 8),
                    Expanded(child: _TrainerStatBox(value: '$liveCatalog', label: 'Live Catalog', tag: 'Published', icon: Icons.published_with_changes, color: AppColors.success)),
                    const SizedBox(width: 8),
                    Expanded(child: _TrainerStatBox(value: '$inReview', label: 'Reviewing', tag: 'Drafts', icon: Icons.pending_actions, color: AppColors.warning)),
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
                        children: [
                          const Text('Catalog Live Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(totalBuilt > 0 ? '${((liveCatalog / totalBuilt) * 100).round()}%' : '0%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.brandTeal)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('$liveCatalog of your $totalBuilt workout programs are published', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: totalBuilt > 0 ? (liveCatalog / totalBuilt) : 0.0,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation(AppColors.brandTeal),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• $liveCatalog Published', style: const TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                          Text('• $inReview In Review/Draft', style: const TextStyle(fontSize: 9, color: AppColors.warning, fontWeight: FontWeight.bold)),
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
                  child: const Row(
                    children: [
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
                  children: [
                    const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutManagementScreen())),
                      child: const Text('View All ↗', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Note loading Supabase data: ${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  )
                else if (docs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('No workouts found in Supabase DB. Tap "CREATE NEW WORKOUT" to get started!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  )
                else
                  ...docs.take(5).map((w) {
                    Color statusColor = AppColors.success;
                    if (w.status.toLowerCase() == 'draft') statusColor = AppColors.warning;
                    if (w.status.toLowerCase() == 'under review') statusColor = AppColors.info;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _activityTile(
                        context,
                        w.title,
                        'Level: ${w.level} • ${w.exercises.length} exercises • ${w.durationMinutes} min',
                        w.status.toUpperCase(),
                        statusColor,
                        'Manage',
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EditWorkoutScreen(workout: w)),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _activityTile(BuildContext context, String title, String sub, String status, Color color, String btnText, VoidCallback onTap) {
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
            onPressed: onTap,
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
