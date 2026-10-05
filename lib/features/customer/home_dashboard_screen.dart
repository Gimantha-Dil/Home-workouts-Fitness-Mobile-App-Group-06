import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/mock_data.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stat_card.dart';
import 'progress_dashboard_screen.dart';
import 'reminders_screen.dart';
import 'safety_guidance_screen.dart';
import 'workout_details_screen.dart';
import 'workout_history_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final today = MockData.workouts.first;

    final quickAccess = [
      ('Progress', 'Analytics', Icons.trending_up, AppColors.brandTeal, const ProgressDashboardScreen()),
      ('History', 'Logs', Icons.history, AppColors.info, const WorkoutHistoryScreen()),
      ('Reminders', '7:00 AM', Icons.notifications_active_outlined, AppColors.purple, const RemindersScreen()),
      ('Safety', 'Guidance', Icons.shield_outlined, AppColors.warning, SafetyGuidanceScreen(workout: today)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircleAvatar(radius: 3, backgroundColor: AppColors.brandTeal),
                          SizedBox(width: 4),
                          Text('FITPULSE PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Hello ${user?.name.split(' ').first ?? 'Nethmi'} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const Text('Keep going! You\'re doing great!', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: NotificationIconButton(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Today's Workout Hero Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3D3A), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: today))),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
                              child: const Text("TODAY'S WORKOUT", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                            const SizedBox(height: 8),
                            Text(today.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('${today.durationMinutes} min • ${today.exercises.length} exercises\nDay 4 of 30 • Level 1',
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, height: 1.3)),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.brandTealDark,
                                minimumSize: const Size(120, 38),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: today))),
                              child: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 100,
                          height: 110,
                          color: Colors.black26,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen())),
                  child: const Text('View History', style: TextStyle(color: AppColors.brandTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(child: StatCard(label: 'Workouts', value: '3', trailing: 'This Week', icon: Icons.fitness_center, color: AppColors.brandTeal)),
                SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Minutes', value: '45', trailing: 'This Week', icon: Icons.timer_outlined, color: AppColors.info)),
                SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Days', value: '12', trailing: 'Active Streak', icon: Icons.local_fire_department, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Quick Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: quickAccess
                  .map((q) => AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => q.$5)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: q.$4.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: Icon(q.$3, color: q.$4, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(q.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text(q.$2, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            // Daily Motivation Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0D9488)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.bolt, color: Colors.white, size: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DAILY MOTIVATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('"Small steps lead to big changes. You\'ve got this today!"', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
