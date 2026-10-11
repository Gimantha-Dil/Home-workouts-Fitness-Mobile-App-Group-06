import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_guidance_screen.dart';

class AdvisorAnalyticsScreen extends StatelessWidget {
  const AdvisorAnalyticsScreen({super.key});

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> guide) {
    final docId = guide['id'] as String;
    final titleController = TextEditingController(text: guide['title'] ?? '');
    String category = guide['category'] ?? 'Warm-up';
    final contentController = TextEditingController(text: guide['content'] ?? '');
    String status = guide['status'] ?? 'Draft';
    String imageUrl = guide['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          bool uploadingImage = false;
          return AlertDialog(
            title: const Text('Edit Safety Protocol (CRUD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TITLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextField(controller: titleController),
                    const SizedBox(height: 12),
                    const Text('CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextField(controller: TextEditingController(text: category), onChanged: (v) => category = v),
                    const SizedBox(height: 12),
                    const Text('CONTENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextField(controller: contentController, maxLines: 4),
                    const SizedBox(height: 12),
                    const Text('GUIDANCE IMAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: AppColors.textSecondary),
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.brandTeal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              setDialogState(() => uploadingImage = true);
                              try {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                                if (pickedFile != null) {
                                  final bytes = await pickedFile.readAsBytes();
                                  final url = await SupabaseService.uploadUserPhoto(
                                    fileName: pickedFile.name,
                                    photoBytes: bytes,
                                  );
                                  setDialogState(() {
                                    imageUrl = url;
                                    uploadingImage = false;
                                  });
                                } else {
                                  setDialogState(() => uploadingImage = false);
                                }
                              } catch (e) {
                                setDialogState(() => uploadingImage = false);
                                if (context.mounted) _showSnack(context, 'Image upload failed: $e');
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined, size: 16, color: AppColors.brandTeal),
                            label: const Text('Change Image from Device', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: ['Published', 'Draft', 'Pending'].contains(status) ? status : 'Published',
                      items: const ['Published', 'Draft', 'Pending']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => status = v!,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
                onPressed: () async {
                  final newTitle = titleController.text.trim();
                  final newContent = contentController.text.trim();
                  if (newTitle.isEmpty) return;

                  try {
                    await FirebaseFirestore.instance.collection('safetyContent').doc(docId).update({
                      'title': newTitle,
                      'category': category,
                      'content': newContent,
                      'status': status,
                      'imageUrl': imageUrl,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.of(ctx).pop();
                    if (context.mounted) _showSnack(context, 'Protocol updated successfully!');
                  } catch (e) {
                    if (context.mounted) _showSnack(context, 'Update failed: $e');
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Protocol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Permanently delete "$title"?', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('safetyContent').doc(docId).delete();
                Navigator.of(ctx).pop();
                if (context.mounted) _showSnack(context, 'Protocol deleted successfully!');
              } catch (e) {
                if (context.mounted) _showSnack(context, 'Delete failed: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final uid = user?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Clinical Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.brandTeal),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateGuidanceScreen())),
            tooltip: 'Create New Guidance',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('safetyContent')
              .where('createdBy', isEqualTo: uid)
              .snapshots(),
          builder: (context, safetySnapshot) {
            final safetyDocs = safetySnapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            final publishedCount = safetyDocs.where((g) => g['status'] == 'Published').length;
            final draftCount = safetyDocs.where((g) => g['status'] == 'Draft' || g['status'] == 'Pending').length;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('advisorFeedback')
                  .where('advisorId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, feedbackSnapshot) {
                final feedbackDocs = feedbackSnapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];
                double avgRating = 4.9;
                if (feedbackDocs.isNotEmpty) {
                  final totalScore = feedbackDocs.fold<double>(0.0, (sum, f) => sum + ((f['rating'] ?? 5.0) as num).toDouble());
                  avgRating = totalScore / feedbackDocs.length;
                }

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Top Overview Card with Chart
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SAFETY PROTOCOL DISTRIBUTION CHART', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: safetyDocs.isEmpty
                                ? const Center(child: Text('No protocols created yet to chart.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                                : PieChart(
                                    PieChartData(
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          color: AppColors.brandTeal,
                                          value: publishedCount.toDouble() > 0 ? publishedCount.toDouble() : 0.1,
                                          title: 'Published ($publishedCount)',
                                          radius: 50,
                                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        PieChartSectionData(
                                          color: AppColors.warning,
                                          value: draftCount.toDouble() > 0 ? draftCount.toDouble() : 0.1,
                                          title: 'Drafts ($draftCount)',
                                          radius: 50,
                                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _legendDot(AppColors.brandTeal, 'Published ($publishedCount)'),
                              const SizedBox(width: 16),
                              _legendDot(AppColors.warning, 'Drafts ($draftCount)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Customer Feedback & Reviews Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CUSTOMER & PATIENT FEEDBACK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text('${avgRating.toStringAsFixed(1)} (${feedbackDocs.length} Reviews)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (feedbackDocs.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: Color(0xFFE0F2FE), child: Icon(Icons.rate_review_outlined, color: AppColors.info, size: 18)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('No Customer Reviews Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text('Patient ratings and clinical feedback will appear here in real-time.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...feedbackDocs.map((f) {
                        final customerName = f['customerName'] ?? 'Patient / Subscriber';
                        final comment = f['comment'] ?? 'Very helpful clinical guidance!';
                        final rating = ((f['rating'] ?? 5.0) as num).toDouble();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(radius: 16, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.person_outline, color: AppColors.brandTeal, size: 18)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          Row(
                                            children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 12)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comment, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 20),

                    // Full CRUD Management List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FULL SAFETY GUIDANCE CRUD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                        Text('${safetyDocs.length} Total', style: const TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (safetyDocs.isEmpty)
                      const Center(child: Text('No protocols found.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                    else
                      ...safetyDocs.map((g) {
                        final title = g['title'] ?? 'Protocol';
                        final category = g['category'] ?? 'General';
                        final status = g['status'] ?? 'Draft';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 14, backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.shield_outlined, color: AppColors.brandTeal, size: 16)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text('$category • $status', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandTeal),
                                  onPressed: () => _showEditDialog(context, g),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                  onPressed: () => _showDeleteConfirmation(context, g['id'], title),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ],
    );
  }
}
