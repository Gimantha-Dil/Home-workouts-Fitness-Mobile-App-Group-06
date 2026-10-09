import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'advisor_chat_screen.dart';

class AdvisorItem {
  final String id;
  final String name;
  final String specialty;
  final String license;
  final double rating;
  final int guidelinesCount;
  final String? photoUrl;

  const AdvisorItem({
    required this.id,
    required this.name,
    required this.specialty,
    required this.license,
    required this.rating,
    required this.guidelinesCount,
    this.photoUrl,
  });
}

class AdvisorSelectionScreen extends StatefulWidget {
  const AdvisorSelectionScreen({super.key});

  @override
  State<AdvisorSelectionScreen> createState() => _AdvisorSelectionScreenState();
}

class _AdvisorSelectionScreenState extends State<AdvisorSelectionScreen> {
  final List<AdvisorItem> _defaultAdvisors = const [
    AdvisorItem(
      id: 'adv_silva_101',
      name: 'Dr. Silva Fernando',
      specialty: 'Cardiology & Sports Medicine',
      license: 'SLMC #48921',
      rating: 4.9,
      guidelinesCount: 12,
      photoUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop',
    ),
    AdvisorItem(
      id: 'adv_anusha_102',
      name: 'Dr. Anusha Perera',
      specialty: 'Physiotherapy & Rehabilitation',
      license: 'SLMC #51204',
      rating: 4.8,
      guidelinesCount: 8,
      photoUrl: 'https://images.unsplash.com/photo-1594824813566-88855ce7890b?w=400&auto=format&fit=crop',
    ),
    AdvisorItem(
      id: 'adv_kasun_103',
      name: 'Dr. Kasun Wickramasinghe',
      specialty: 'Orthopedic & Joint Safety',
      license: 'SLMC #39812',
      rating: 4.9,
      guidelinesCount: 10,
      photoUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop',
    ),
  ];

  Future<void> _selectAdvisor(AdvisorItem advisor) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'assignedAdvisorId': advisor.id,
        'assignedAdvisorName': advisor.name,
        'assignedAdvisorSpecialty': advisor.specialty,
        'assignedAdvisorPhotoUrl': advisor.photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚡ ${advisor.name} selected as your Medical Advisor!'),
            backgroundColor: AppColors.brandTeal,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error selecting advisor: $e');
    }
  }

  Future<void> _unselectAdvisor() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'assignedAdvisorId': FieldValue.delete(),
        'assignedAdvisorName': FieldValue.delete(),
        'assignedAdvisorSpecialty': FieldValue.delete(),
        'assignedAdvisorPhotoUrl': FieldValue.delete(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical Advisor unselected. Choose any advisor below.')),
        );
      }
    } catch (e) {
      debugPrint('Error unselecting advisor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = fb.FirebaseAuth.instance.currentUser;

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
        title: const Text('Healthcare Advisors (Doctors)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid ?? '').snapshots(),
          builder: (context, docSnap) {
            final data = docSnap.data?.data();
            final assignedId = data?['assignedAdvisorId']?.toString();
            final assignedName = data?['assignedAdvisorName']?.toString();
            final assignedSpecialty = data?['assignedAdvisorSpecialty']?.toString() ?? 'Sports Medicine';
            final assignedPhotoUrl = data?['assignedAdvisorPhotoUrl']?.toString();

            final hasAssigned = assignedId != null && assignedId.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Assigned Advisor Hero Banner Card
                if (hasAssigned) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3D3A), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                              child: const Text('YOUR ASSIGNED MEDICAL ADVISOR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                              child: const Text('ACTIVE SUPERVISION', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white24,
                              child: ClipOval(
                                child: AppNetworkImage(
                                  url: assignedPhotoUrl,
                                  width: 56,
                                  height: 56,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(assignedName ?? 'Dr. Silva Fernando', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(assignedSpecialty, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                                  const SizedBox(height: 2),
                                  const Text('SLMC Certified • Medical Safety Supervision', style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.brandTealDark,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  minimumSize: const Size.fromHeight(38),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AdvisorChatScreen(
                                        advisorId: assignedId,
                                        advisorName: assignedName ?? 'Dr. Silva Fernando',
                                        advisorSpecialty: assignedSpecialty,
                                        advisorPhotoUrl: assignedPhotoUrl,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: const Text('Message Doctor 💬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size(100, 38),
                              ),
                              onPressed: _unselectAdvisor,
                              icon: const Icon(Icons.swap_horiz, size: 16),
                              label: const Text('Change 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text('Available Medical Advisors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Select a certified medical doctor to supervise your workout safety guidelines:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 12),

                // Stream Advisors from Firestore
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'advisor')
                      .snapshots(),
                  builder: (context, snap) {
                    final docs = snap.data?.docs ?? [];
                    List<AdvisorItem> advisors = [];

                    if (docs.isNotEmpty) {
                      advisors = docs.map((d) {
                        final data = d.data();
                        return AdvisorItem(
                          id: d.id,
                          name: data['name'] ?? 'Dr. Advisor',
                          specialty: data['specialty'] ?? 'Sports Medicine & Cardiology',
                          license: data['license'] ?? 'SLMC Certified',
                          rating: (data['rating'] as num?)?.toDouble() ?? 4.9,
                          guidelinesCount: (data['guidelinesCount'] as num?)?.toInt() ?? 8,
                          photoUrl: data['photoUrl'] ?? data['profilePhotoUrl'],
                        );
                      }).toList();
                    } else {
                      advisors = _defaultAdvisors;
                    }

                    return Column(
                      children: advisors.map((adv) {
                        final isSelected = assignedId == adv.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFFCCFBF1),
                                      child: ClipOval(
                                        child: AppNetworkImage(
                                          url: adv.photoUrl,
                                          width: 48,
                                          height: 48,
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
                                              Text(adv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified, color: AppColors.brandTeal, size: 14),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(adv.specialty, style: const TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text('${adv.license} • ${adv.guidelinesCount} Guidelines', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, size: 12, color: AppColors.warning),
                                          const SizedBox(width: 2),
                                          Text('${adv.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: isSelected
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(8)),
                                              child: const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle, size: 14, color: AppColors.brandTeal),
                                                  SizedBox(width: 6),
                                                  Text('Your Active Advisor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                                ],
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.brandTeal,
                                                minimumSize: const Size.fromHeight(36),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              onPressed: () => _selectAdvisor(adv),
                                              child: const Text('Select as My Advisor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.brandTeal,
                                        side: const BorderSide(color: AppColors.brandTeal),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        minimumSize: const Size(100, 36),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AdvisorChatScreen(
                                              advisorId: adv.id,
                                              advisorName: adv.name,
                                              advisorSpecialty: adv.specialty,
                                              advisorPhotoUrl: adv.photoUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat_bubble_outline, size: 14),
                                      label: const Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
