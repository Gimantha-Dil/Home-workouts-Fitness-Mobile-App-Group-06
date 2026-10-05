import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_guidance_screen.dart';
import 'health_considerations_screen.dart';
import 'safety_content_screen.dart';

class AdvisorDashboardScreen extends StatelessWidget {
  const AdvisorDashboardScreen({super.key});

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
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Good morning, Dr. Silva', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Here\'s what\'s happening today.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
            // Stat Cards Row
            Row(
              children: const [
                Expanded(child: _AdvisorStatBox(value: '12', label: 'Safety Guides', tag: 'Active', icon: Icons.shield_outlined, color: AppColors.brandTeal)),
                SizedBox(width: 8),
                Expanded(child: _AdvisorStatBox(value: '3', label: 'Pending', tag: 'Needs action', icon: Icons.pending_actions, color: AppColors.warning)),
                SizedBox(width: 8),
                Expanded(child: _AdvisorStatBox(value: '5', label: 'Messages', tag: 'Unread', icon: Icons.chat_bubble_outline, color: AppColors.info)),
              ],
            ),
            const SizedBox(height: 16),
            // Consult Rhythm Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('WEEKLY CONSULT RHYTHM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.info, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('84 Inquiries Resolved', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('↗ 98.4% On-time clinical response', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.show_chart, color: AppColors.info, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('QUICK ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('Shortcuts', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateGuidanceScreen())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Guidance →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SafetyContentScreen())),
              icon: const Icon(Icons.shield_outlined, size: 18, color: AppColors.textPrimary),
              label: const Text('View Safety Content →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthConsiderationsScreen())),
              icon: const Icon(Icons.health_and_safety_outlined, size: 18, color: AppColors.textPrimary),
              label: const Text('View Users\' Health Info →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('RECENT ACTIVITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('Today', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            _activityTile('New user query', 'Question about knee pain during exercise', 'Joint Stress', '2h ago'),
            const SizedBox(height: 8),
            _activityTile('Safety content updated', 'Warm-up guide for beginners', 'Live in app', '4h ago'),
            const SizedBox(height: 8),
            _activityTile('New message', 'From Trainer (Alex Carter) Re: Heart rate ranges', 'Unread', '6h ago'),
            const SizedBox(height: 16),
            // Clinical Protocol Note Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3D3A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  Icon(Icons.assignment_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLINICAL PROTOCOL NOTE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                        SizedBox(height: 2),
                        Text('Updated knee flexure guidelines approved →', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _activityTile(String title, String desc, String badge, String time) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.medical_services_outlined, color: AppColors.brandTeal, size: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                  child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorStatBox extends StatelessWidget {
  final String value;
  final String label;
  final String tag;
  final IconData icon;
  final Color color;

  const _AdvisorStatBox({required this.value, required this.label, required this.tag, required this.icon, required this.color});

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
