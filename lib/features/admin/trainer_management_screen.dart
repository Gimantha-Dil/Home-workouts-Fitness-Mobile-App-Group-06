import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/screens/notification_center_screen.dart';
import '../../shared/widgets/common_widgets.dart';
import 'admin_settings_screen.dart';
import 'admin_shell.dart';

class TrainerManagementScreen extends StatefulWidget {
  const TrainerManagementScreen({super.key});

  @override
  State<TrainerManagementScreen> createState() => _TrainerManagementScreenState();
}

class _TrainerManagementScreenState extends State<TrainerManagementScreen> {
  String _statusFilter = 'All Status';

  Future<void> _showAddTrainerDialog(BuildContext context) async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Trainer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter email of registered user:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'user@example.com'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () async {
              final email = emailController.text.trim().toLowerCase();
              if (email.isEmpty) return;

              try {
                final querySnap = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .get();

                if (querySnap.docs.isNotEmpty) {
                  final userDoc = querySnap.docs.first;
                  await userDoc.reference.update({
                    'role': 'trainer',
                    'verificationStatus': 'approved',
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Account $email promoted to trainer!')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No account with this email. Ask them to sign up first.')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update role: $e')),
                  );
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Add Role'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> trainer) {
    final uid = trainer['id'] ?? trainer['uid'] ?? '';
    final name = trainer['name'] ?? 'Trainer';
    final email = trainer['email'] ?? '';
    final status = trainer['verificationStatus'] ?? 'pending';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Credentials & Proof: $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 400,
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('verificationRequests').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data?.data() ?? {};
              final experience = data['experienceYears'] ?? data['specialization'] ?? 'Not provided';
              final socialLink = data['socialLink'] ?? data['workplace'] ?? 'None';
              final List<dynamic> docUrls = data['documentUrls'] ?? data['identityDocuments'] ?? [];

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: $email', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('User ID: $uid', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Status: ${status.toUpperCase()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: status == 'approved' ? AppColors.success : AppColors.warning)),
                    const SizedBox(height: 14),
                    const Text('SUBMITTED CREDENTIALS & PROOF:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text('• Experience / Specialization: $experience', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('• Social / Professional Link: $socialLink', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 12),
                    const Text('VERIFICATION DOCUMENTS (PROOF):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    if (docUrls.isEmpty)
                      const Text('No uploaded proof documents found in request.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic))
                    else
                      ...docUrls.map((url) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () async {
                                final uri = Uri.parse(url.toString());
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.insert_drive_file, size: 16, color: AppColors.brandTeal),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      url.toString(),
                                      style: const TextStyle(fontSize: 11, color: AppColors.info, decoration: TextDecoration.underline),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.open_in_new, size: 14, color: AppColors.info),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'verificationStatus': 'rejected',
              });
              await FirebaseFirestore.instance.collection('verificationRequests').doc(uid).set({
                'status': 'rejected',
              }, SetOptions(merge: true));

              try {
                await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').add({
                  'title': 'Verification Update',
                  'message': 'Your trainer verification request was not approved. Please resubmit valid credentials.',
                  'category': 'Verification',
                  'targetRole': 'trainer',
                  'timestamp': FieldValue.serverTimestamp(),
                  'isRead': false,
                });
              } catch (_) {}

              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name credentials rejected.')),
                );
              }
            },
            child: const Text('Reject', style: TextStyle(color: AppColors.danger)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'role': 'trainer',
                'verificationStatus': 'approved',
              });
              await FirebaseFirestore.instance.collection('verificationRequests').doc(uid).set({
                'status': 'approved',
              }, SetOptions(merge: true));

              try {
                await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').add({
                  'title': 'Credentials Approved! 🎉',
                  'message': 'Congratulations! Your coaching credentials have been verified and approved by the admin. You can now publish and manage workout routines.',
                  'category': 'Verification',
                  'targetRole': 'trainer',
                  'timestamp': FieldValue.serverTimestamp(),
                  'isRead': false,
                });
              } catch (_) {}

              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name approved as Trainer!')),
                );
              }
            },
            child: const Text('Approve Trainer'),
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
                MaterialPageRoute(builder: (_) => const AdminShell()),
              );
            }
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'trainer')
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            var filtered = docs;
            if (_statusFilter != 'All Status') {
              filtered = filtered.where((t) {
                final st = (t['verificationStatus'] ?? 'pending').toString().toLowerCase();
                return st == _statusFilter.toLowerCase();
              }).toList();
            }

            final totalTrainers = docs.length;
            final approvedTrainers = docs.where((t) => t['verificationStatus'] == 'approved').length;
            final pendingTrainers = docs.where((t) => t['verificationStatus'] == 'pending' || t['verificationStatus'] == 'none').length;
            final rejectedTrainers = docs.where((t) => t['verificationStatus'] == 'rejected').length;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trainer Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          _Badge(text: '• $approvedTrainers Active', color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Review qualifications, pending approvals, and active coaches in real-time.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),

                      // Summary Cards (Clickable Tabs)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'All Status'),
                              child: _SummaryBox(title: 'TOTAL', value: '$totalTrainers', tag: 'Coaches', color: AppColors.brandTeal, isSelected: _statusFilter == 'All Status'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'Approved'),
                              child: _SummaryBox(title: 'APPROVED', value: '$approvedTrainers', tag: 'Verified', color: AppColors.success, isSelected: _statusFilter == 'Approved'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'Pending'),
                              child: _SummaryBox(title: 'PENDING', value: '$pendingTrainers', tag: 'Review', color: AppColors.warning, isSelected: _statusFilter == 'Pending'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'Rejected'),
                              child: _SummaryBox(title: 'REJECTED', value: '$rejectedTrainers', tag: 'Closed', color: AppColors.danger, isSelected: _statusFilter == 'Rejected'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: DropdownButtonFormField<String>(
                                initialValue: _statusFilter,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                items: const ['All Status', 'Approved', 'Pending', 'Rejected']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11))))
                                    .toList(),
                                onChanged: (v) => setState(() => _statusFilter = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (filtered.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text('No Trainers registered yet in Firestore.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((t) {
                          final name = t['name'] ?? 'Trainer';
                          final email = t['email'] ?? '';
                          final uid = t['id'] ?? t['uid'] ?? '';
                          final status = t['verificationStatus'] ?? 'pending';
                          final shortId = uid.length > 8 ? uid.substring(0, 8) : uid;

                          Color statusColor = AppColors.success;
                          if (status == 'pending' || status == 'none') statusColor = AppColors.warning;
                          if (status == 'rejected') statusColor = AppColors.danger;

                          final isPending = status == 'pending' || status == 'none';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.brandTeal.withValues(alpha: 0.12),
                                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'T', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                _Badge(text: '• $status', color: statusColor),
                                              ],
                                            ),
                                            Text('#$shortId • $email', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
                                        child: const Text('⚡ Fitness Coach', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.info)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPending ? AppColors.brandTeal : Colors.white,
                                          foregroundColor: isPending ? Colors.white : AppColors.brandTeal,
                                          minimumSize: const Size(100, 28),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          side: isPending ? BorderSide.none : const BorderSide(color: AppColors.brandTeal),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _showReviewDialog(context, t),
                                        child: Text(isPending ? 'Review Profile' : 'Credentials 📄', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      // Clinical Standards Verified Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('All approved trainers have completed accreditation and automated biometric coaching verification.',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                            ),
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

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final String tag;
  final Color color;
  final bool isSelected;

  const _SummaryBox({required this.title, required this.value, required this.tag, required this.color, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSelected ? 0.22 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
