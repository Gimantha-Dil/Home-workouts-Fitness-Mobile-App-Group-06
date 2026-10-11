import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import '../customer/advisor_chat_screen.dart';
import 'advisor_analytics_screen.dart';
import 'create_guidance_screen.dart';
import 'health_considerations_screen.dart';
import 'safety_content_screen.dart';

class AdvisorDashboardScreen extends StatelessWidget {
  const AdvisorDashboardScreen({super.key});

  void _showGuideOptions(BuildContext context, Map<String, dynamic> guide) {
    final docId = guide['id'] as String;
    final title = guide['title'] ?? '';
    final category = guide['category'] ?? 'Warm-up';
    final content = guide['content'] ?? '';
    final status = guide['status'] ?? 'Draft';
    final imageUrl = guide['imageUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                  child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Category: $category', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFCCFBF1), child: Icon(Icons.edit_outlined, color: AppColors.brandTeal)),
              title: const Text('Edit Guidance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Modify title, content, category or status', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showEditDialog(context, docId, title, category, content, status, imageUrl);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFEF2F2), child: Icon(Icons.delete_outline, color: AppColors.danger)),
              title: const Text('Delete Guidance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger)),
              subtitle: const Text('Permanently remove from database', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showDeleteConfirmation(context, docId, title);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, String initialTitle, String initialCategory, String initialContent, String initialStatus, String initialImageUrl) {
    final titleController = TextEditingController(text: initialTitle);
    String category = initialCategory;
    final contentController = TextEditingController(text: initialContent);
    String status = initialStatus;
    String imageUrl = initialImageUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          bool uploadingImage = false;
          return AlertDialog(
            title: const Text('Edit Safety Guidance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    DropdownButtonFormField<String>(
                      initialValue: ['Warm-up', 'Cool-down', 'Precautions', 'Warning Signs', 'Health Considerations'].contains(category) ? category : 'Warm-up',
                      items: const ['Warm-up', 'Cool-down', 'Precautions', 'Warning Signs', 'Health Considerations']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => category = v!,
                    ),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Image upload failed: $e')),
                                );
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
                      initialValue: ['Published', 'Draft', 'Pending'].contains(status) ? status : 'Published',
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
              TextButton(
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
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Safety guidance updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                },
                child: const Text('Save Changes', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
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
        title: const Text('Delete Safety Guidance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Safety guidance deleted successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _activityTile(BuildContext context, Map<String, dynamic> guide) {
    final title = guide['title'] ?? 'Safety Protocol';
    final desc = guide['category'] ?? 'General Safety';
    final badge = (guide['status'] ?? 'Published').toUpperCase();

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _showGuideOptions(context, guide),
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
                    const Text('Firestore DB', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                      child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.brandTeal),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit Guidance',
                      onPressed: () => _showEditDialog(
                        context,
                        guide['id'],
                        title,
                        desc,
                        guide['content'] ?? '',
                        guide['status'] ?? 'Published',
                        guide['imageUrl'] ?? '',
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: 'Delete Guidance',
                      onPressed: () => _showDeleteConfirmation(context, guide['id'], title),
                    ),
                  ],
                ),
              ],
            ),
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

                // Patient Consultations & Messages Section
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PATIENT CONSULTATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    Text('Live Firestore Chat', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('chats').snapshots(),
                  builder: (context, chatSnap) {
                    final allChats = chatSnap.data?.docs.map((d) => d.data()).toList() ?? [];

                    final myChats = allChats.where((c) {
                      final advUid = c['advisorUid']?.toString() ?? '';
                      final advName = (c['advisorName'] ?? '').toString().toLowerCase();
                      final myName = (user?.name ?? '').toLowerCase();

                      final isMyUid = uid.isNotEmpty && (advUid == uid || c['id']?.toString().contains(uid) == true);
                      final isMyName = myName.isNotEmpty && advName.contains(myName);

                      return isMyUid || isMyName;
                    }).toList();

                    if (myChats.isEmpty) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdvisorChatScreen(
                                advisorId: uid.isNotEmpty ? uid : 'adv_biyuni_104',
                                advisorName: user?.name ?? 'Dr. Biyuni Tharuka',
                                advisorSpecialty: 'Sports Medicine & Cardiology',
                                advisorPhotoUrl: user?.profilePhotoUrl,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFCCFBF1),
                                child: Icon(Icons.chat_bubble_outline, color: AppColors.brandTeal, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('No Pending Patient Messages for ${user?.name ?? "You"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('When trainees message ${user?.name ?? "you"}, their health queries appear here in real-time.', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: myChats.map((c) {
                        final customerName = c['customerName']?.toString() ?? 'Trainee Patient';
                        final customerUid = c['customerUid']?.toString();
                        final lastMsg = c['lastMessage']?.toString() ?? 'Consultation question';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AdvisorChatScreen(
                                    advisorId: uid.isNotEmpty ? uid : 'adv_biyuni_104',
                                    advisorName: user?.name ?? 'Dr. Biyuni Tharuka',
                                    advisorSpecialty: 'Sports Medicine & Cardiology',
                                    advisorPhotoUrl: user?.profilePhotoUrl,
                                    customerUid: customerUid,
                                    customerName: customerName,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFE0F2FE),
                                  child: Icon(Icons.person, color: AppColors.info, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(lastMsg, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brandTeal,
                                    minimumSize: const Size(80, 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AdvisorChatScreen(
                                          advisorId: uid.isNotEmpty ? uid : 'adv_biyuni_104',
                                          advisorName: user?.name ?? 'Dr. Biyuni Tharuka',
                                          advisorSpecialty: 'Sports Medicine & Cardiology',
                                          advisorPhotoUrl: user?.profilePhotoUrl,
                                          customerUid: customerUid,
                                          customerName: customerName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Reply', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
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
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvisorAnalyticsScreen())),
                  icon: const Icon(Icons.analytics_outlined, size: 18, color: AppColors.brandTeal),
                  label: const Text('Clinical Analytics →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _activityTile(context, g),
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
}

class _AdvisorStatBox extends StatelessWidget {
  final String value;
  final String label;
  final String tag;
  final IconData icon;
  final Color color;

  const _AdvisorStatBox({
    required this.value,
    required this.label,
    this.tag = '',
    required this.icon,
    required this.color,
  });

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
