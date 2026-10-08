import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_guidance_screen.dart';
import 'health_considerations_screen.dart';
import 'safety_content_screen.dart';

class AdvisorDashboardScreen extends StatelessWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final uid = user?.id ?? '';

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
                Text('Good morning, ${user?.name ?? 'Advisor'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Text('Clinical Dashboard • Live Firestore DB', style: TextStyle(fontSize: 9, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('safetyContent')
              .where('createdBy', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            final totalGuides = docs.length;
            final activeGuides = docs.where((g) => g['status'] == 'Published').length;
            final pendingGuides = docs.where((g) => g['status'] == 'Draft' || g['status'] == 'Pending').length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stat Cards Row
                Row(
                  children: [
                    Expanded(child: _AdvisorStatBox(value: '$totalGuides', label: 'Safety Guides', tag: 'Total', icon: Icons.shield_outlined, color: AppColors.brandTeal)),
                    const SizedBox(width: 8),
                    Expanded(child: _AdvisorStatBox(value: '$activeGuides', label: 'Active', tag: 'Live in App', icon: Icons.check_circle_outline, color: AppColors.success)),
                    const SizedBox(width: 8),
                    Expanded(child: _AdvisorStatBox(value: '$pendingGuides', label: 'Drafts', tag: 'Building', icon: Icons.pending_actions, color: AppColors.warning)),
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
                          children: [
                            const Text('WEEKLY CONSULT RHYTHM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.info, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text('$activeGuides Clinical Protocols Live', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            const Text('↗ 100% Doctor-verified clinical safety', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.show_chart, color: AppColors.info, size: 36),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RECENT SAFETY GUIDES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    Text('Realtime DB', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (docs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('No safety guidance protocols published yet. Tap "Create Guidance" to add one!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  )
                else
                  ...docs.take(5).map((g) {
                    final title = g['title'] ?? 'Safety Protocol';
                    final category = g['category'] ?? 'General Safety';
                    final status = g['status'] ?? 'Published';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _activityTile(title, category, status.toUpperCase(), 'Firestore DB'),
                    );
                  }),

                const SizedBox(height: 16),
                // Clinical Protocol Note Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3D3A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CLINICAL PROTOCOL NOTE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                            SizedBox(height: 2),
                            Text('Medical safety guidance connected to Firestore DB →', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
