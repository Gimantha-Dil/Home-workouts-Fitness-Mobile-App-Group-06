import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _finishOnboarding() {
    context.read<AuthProvider>().completeOnboarding();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _buildPage1(context),
                  _buildPage2(context),
                  _buildPage3(context),
                ],
              ),
            ),
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AppColors.brandTeal : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Primary Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                label: _index == 0
                    ? 'Next →'
                    : _index == 1
                        ? 'Continue →'
                        : 'Get Started ✓',
                onPressed: () {
                  if (_index < 2) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finishOnboarding();
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                _index == 0
                    ? 'Skip to Sign In'
                    : 'Already have an account? Sign In',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Onboarding Page 1 (Centered Layout)
  Widget _buildPage1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Fitness Journey\nStarts Here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.25),
          ),
          const SizedBox(height: 10),
          const Text(
            'Easy home workouts, expert guidance and progress tracking — all in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Onboarding Page 2 (Centered Layout)
  Widget _buildPage2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 24),
                  SizedBox(width: 6),
                  Text('FitPulse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.brandTeal)),
                ],
              ),
              TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          // Graphic Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFCCFBF1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.brandTeal,
                      child: Icon(Icons.self_improvement, color: Colors.white, size: 38),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.bolt, size: 14, color: AppColors.brandTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome, size: 13, color: AppColors.brandTeal),
                      SizedBox(width: 6),
                      Text('Adaptive Plans: AI Guided', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'Personalized Workouts\nTailored to You',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.25),
          ),
          const SizedBox(height: 8),
          const Text(
            'Custom workout plans created by certified trainers, tailored to your schedule, fitness level, and equipment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _FeatureBadge(icon: Icons.timer_outlined, title: '15-30 Min', sub: 'Quick & Daily')),
              SizedBox(width: 8),
              Expanded(child: _FeatureBadge(icon: Icons.verified_user_outlined, title: 'Coach Verified', sub: '100% Safe')),
              SizedBox(width: 8),
              Expanded(child: _FeatureBadge(icon: Icons.fitness_center_outlined, title: 'No Equipment', sub: 'Bodyweight')),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // Onboarding Page 3 (Redesigned Beautiful Card & Centered Layout)
  Widget _buildPage3(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 24),
                  SizedBox(width: 6),
                  Text('FitPulse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.brandTeal)),
                ],
              ),
              TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          // Beautiful Redesigned Card for Page 3
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFCCFBF1), Color(0xFFE0F2FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: const [
                          Icon(Icons.local_fire_department, size: 14, color: AppColors.warning),
                          SizedBox(width: 4),
                          Text('7-Day Streak!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: const [
                          Icon(Icons.emoji_events, size: 14, color: AppColors.brandTeal),
                          SizedBox(width: 4),
                          Text('Level 3 Pro', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Circular Milestone Badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Column(
                    children: const [
                      Icon(Icons.trending_up, color: AppColors.brandTeal, size: 24),
                      SizedBox(height: 2),
                      Text('+34%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Goal reached today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Daily Target Progress', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    Text('85% Complete', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 7,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(AppColors.brandTeal),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'Track Your Daily Progress &\nMilestones',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.25),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay accountable with consistency streaks, detailed calorie metrics, workout reminders, and doctor-verified safety tips.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _FeatureBadge(icon: Icons.local_fire_department_outlined, title: 'Calorie Logs', sub: 'Burn metrics')),
              SizedBox(width: 8),
              Expanded(child: _FeatureBadge(icon: Icons.notifications_outlined, title: 'Reminders', sub: 'Custom alerts')),
              SizedBox(width: 8),
              Expanded(child: _FeatureBadge(icon: Icons.shield_outlined, title: 'Safety First', sub: 'Doctor tips')),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;

  const _FeatureBadge({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.brandTeal),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
