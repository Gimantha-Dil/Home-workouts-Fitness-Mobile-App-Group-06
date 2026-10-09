import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'customer_shell.dart';
import 'goal_selection_screen.dart';
import 'profile_screen.dart';

class GoalsAchievementsScreen extends StatelessWidget {
  const GoalsAchievementsScreen({super.key});

  void _showAchievementDetails(BuildContext context, String title, String desc, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: AppColors.brandTeal, size: 18),
                  SizedBox(width: 8),
                  Text('Achievement Recorded in Firestore', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Awesome!', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMilestoneDetails(BuildContext context, String title, String sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Milestone: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            const Text('Keep completing your daily workouts to unlock this milestone automatically!', style: TextStyle(fontSize: 11, height: 1.3)),
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
        title: const Text('Goals & Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Top Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F3D3A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.trending_up, color: Colors.white, size: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UNSTOPPABLE RHYTHM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('You\'re in the top 8% this week!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Focus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Focus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GoalSelectionScreen()),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text('Edit Target ⚙', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GoalSelectionScreen()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(radius: 14, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.scale, color: AppColors.brandTeal, size: 16)),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Weight Loss', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Targeting healthy metabolic rate', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('IN PROGRESS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress to Target', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text('60% Complete', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 6,
                      backgroundColor: Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(AppColors.brandTeal),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TARGET DATE: Oct 28 (3 wks left)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('WEEKLY PACE: -0.65 kg / week', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Achievements Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Achievements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                InkWell(
                  onTap: () {
                    _showAchievementDetails(
                      context,
                      'All Unlocked Badges (3/4)',
                      'You have unlocked 3 milestone badges so far! Keep training to unlock "Month Master".',
                      Icons.emoji_events,
                      AppColors.brandTeal,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text('3 Unlocked • View All', style: TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _BadgeCard(
                  title: 'First Workout',
                  tag: 'Claimed',
                  icon: Icons.emoji_events,
                  color: AppColors.info,
                  onTap: () => _showAchievementDetails(
                    context,
                    'First Workout Claimed!',
                    'You completed your first active workout session on FitPulse.',
                    Icons.emoji_events,
                    AppColors.info,
                  ),
                ),
                _BadgeCard(
                  title: '7 Day Streak',
                  tag: 'Active Now',
                  icon: Icons.local_fire_department,
                  color: AppColors.warning,
                  onTap: () => _showAchievementDetails(
                    context,
                    '7 Day Consistency Streak!',
                    'You stayed active for 7 consecutive days. Outstanding dedication!',
                    Icons.local_fire_department,
                    AppColors.warning,
                  ),
                ),
                _BadgeCard(
                  title: '10 Workouts',
                  tag: 'Celebrated',
                  icon: Icons.stars,
                  color: AppColors.brandTeal,
                  onTap: () => _showAchievementDetails(
                    context,
                    '10 Workouts Milestone!',
                    'You successfully logged 10 complete workout routines.',
                    Icons.stars,
                    AppColors.brandTeal,
                  ),
                ),
                _BadgeCard(
                  title: 'Month Master',
                  tag: '80% done',
                  icon: Icons.lock_outline,
                  color: AppColors.textSecondary,
                  onTap: () => _showAchievementDetails(
                    context,
                    'Month Master (In Progress)',
                    'Complete 20 workout sessions in a single month to unlock this badge. You are 80% there!',
                    Icons.lock_outline,
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Upcoming Milestones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            AppCard(
              padding: const EdgeInsets.all(12),
              onTap: () => _showMilestoneDetails(context, 'Build Strength', '4 weeks left until kickoff'),
              child: const Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: Color(0xFFE0F2FE), child: Icon(Icons.fitness_center, color: AppColors.info, size: 16)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Build Strength', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('4 weeks left until kickoff', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('Queued', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.info)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            AppCard(
              padding: const EdgeInsets.all(12),
              onTap: () => _showMilestoneDetails(context, 'Run 5K', 'Starting next month (Nov 1)'),
              child: const Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: Color(0xFFF3F4F6), child: Icon(Icons.directions_run, color: AppColors.textSecondary, size: 16)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Run 5K', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Starting next month (Nov 1)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('Planned', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Coach Quote Card
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 120,
                color: Colors.black54,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: AppNetworkImage(
                        url: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop',
                        height: 120,
                        width: double.infinity,
                      ),
                    ),
                    Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(14),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('COACH TIP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(height: 2),
                          Text('"Consistency creates the baseline for peak breakthroughs."', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final String tag;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: Checkbox.width > 0 ? MainAxisAlignment.center : MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
