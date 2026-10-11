import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
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
            content: Text('${advisor.name} selected as your Medical Advisor.'),
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

  void _openDoctorReviewDialog(AdvisorItem advisor) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reviewCtrl = TextEditingController();
    double selectedStars = 5.0;
    bool submitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFCCFBF1),
                child: Icon(Icons.star, color: AppColors.brandTeal, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Rate & Review ${advisor.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How was your consultation and guidance experience?', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              // Interactive Star Rating Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      starVal <= selectedStars ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                      size: 28,
                    ),
                    onPressed: () {
                      setDialogState(() => selectedStars = starVal);
                    },
                  );
                }),
              ),
              Center(
                child: Text('Rating: $selectedStars / 5.0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.brandTeal)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reviewCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Type your feedback or medical advice review here...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
              onPressed: submitting
                  ? null
                  : () async {
                      final reviewText = reviewCtrl.text.trim();
                      if (reviewText.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Please enter your feedback comment.')),
                        );
                        return;
                      }

                      setDialogState(() => submitting = true);

                      try {
                        final reviewDoc = FirebaseFirestore.instance.collection('advisorReviews').doc();
                        await reviewDoc.set({
                          'id': reviewDoc.id,
                          'advisorId': advisor.id,
                          'advisorName': advisor.name,
                          'customerUid': user.uid,
                          'customerName': currentUser?.name ?? 'Trainee Patient',
                          'rating': selectedStars,
                          'review': reviewText,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Also update advisor document rating in Firestore
                        try {
                          final reviewsSnap = await FirebaseFirestore.instance
                              .collection('advisorReviews')
                              .where('advisorId', isEqualTo: advisor.id)
                              .get();

                          if (reviewsSnap.docs.isNotEmpty) {
                            final allRatings = reviewsSnap.docs.map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 5.0).toList();
                            final avgRating = double.parse((allRatings.reduce((a, b) => a + b) / allRatings.length).toStringAsFixed(1));

                            await FirebaseFirestore.instance.collection('users').doc(advisor.id).set({
                              'rating': avgRating,
                              'reviewCount': allRatings.length,
                            }, SetOptions(merge: true));
                          }
                        } catch (_) {}

                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Thank you! Feedback for ${advisor.name} submitted in real-time.'),
                              backgroundColor: AppColors.brandTeal,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => submitting = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Failed to submit feedback: $e')),
                          );
                        }
                      }
                    },
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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

            final assignedAdvisorItem = AdvisorItem(
              id: assignedId ?? '',
              name: assignedName ?? 'Dr. Medical Advisor',
              specialty: assignedSpecialty,
              license: 'SLMC Certified',
              rating: 5.0,
              guidelinesCount: 8,
              photoUrl: assignedPhotoUrl,
            );

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
                                icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.brandTealDark),
                                label: const Text('Message Doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEF3C7),
                                foregroundColor: const Color(0xFF92400E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size(100, 38),
                              ),
                              onPressed: () => _openDoctorReviewDialog(assignedAdvisorItem),
                              icon: const Icon(Icons.star, size: 16, color: AppColors.warning),
                              label: const Text('Rate Doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size(80, 38),
                              ),
                              onPressed: _unselectAdvisor,
                              child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
                                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                      stream: FirebaseFirestore.instance
                                          .collection('advisorReviews')
                                          .where('advisorId', isEqualTo: adv.id)
                                          .snapshots(),
                                      builder: (context, reviewSnap) {
                                        final reviewDocs = reviewSnap.data?.docs ?? [];
                                        double liveRating = adv.rating;
                                        final reviewCount = reviewDocs.length;

                                        if (reviewDocs.isNotEmpty) {
                                          final ratings = reviewDocs.map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 5.0).toList();
                                          liveRating = double.parse((ratings.reduce((a, b) => a + b) / ratings.length).toStringAsFixed(1));
                                        }

                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, size: 12, color: AppColors.warning),
                                              const SizedBox(width: 2),
                                              Text('$liveRating ($reviewCount)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                            ],
                                          ),
                                        );
                                      },
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
                                        foregroundColor: AppColors.warning,
                                        side: const BorderSide(color: AppColors.warning),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        minimumSize: const Size(80, 36),
                                      ),
                                      onPressed: () => _openDoctorReviewDialog(adv),
                                      icon: const Icon(Icons.star_outline, size: 14, color: AppColors.warning),
                                      label: const Text('Rate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.brandTeal,
                                        side: const BorderSide(color: AppColors.brandTeal),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        minimumSize: const Size(60, 36),
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
                                      child: const Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),

                                // Real-Time Live Reviews Section
                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('advisorReviews')
                                      .where('advisorId', isEqualTo: adv.id)
                                      .snapshots(),
                                  builder: (context, reviewSnap) {
                                    final reviews = reviewSnap.data?.docs.map((d) => d.data()).toList() ?? [];
                                    if (reviews.isEmpty) return const SizedBox.shrink();

                                    final latestReview = reviews.first;
                                    final customerName = latestReview['customerName'] ?? 'Trainee';
                                    final comment = latestReview['review'] ?? '';
                                    final ratingVal = (latestReview['rating'] as num?)?.toDouble() ?? 5.0;

                                    return Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFF3F4F6)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.format_quote, size: 14, color: AppColors.brandTeal),
                                              const SizedBox(width: 4),
                                              Text('Latest Review by $customerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textPrimary)),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, size: 10, color: AppColors.warning),
                                                  const SizedBox(width: 2),
                                                  Text('$ratingVal', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.warning)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text('"$comment"', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    );
                                  },
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
