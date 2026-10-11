import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/screens/notification_center_screen.dart';
import '../../shared/widgets/common_widgets.dart';
import 'admin_settings_screen.dart';
import 'admin_shell.dart';

class AdvisorManagementScreen extends StatefulWidget {
  const AdvisorManagementScreen({super.key});

  @override
  State<AdvisorManagementScreen> createState() => _AdvisorManagementScreenState();
}

class _AdvisorManagementScreenState extends State<AdvisorManagementScreen> {
  String _statusFilter = 'All Status';

  void _showReviewDialog(BuildContext context, Map<String, dynamic> advisor) {
    final uid = advisor['id'] ?? advisor['uid'] ?? '';
    final name = advisor['name'] ?? 'Healthcare Advisor';
    final email = advisor['email'] ?? '';
    final status = advisor['verificationStatus'] ?? 'pending';

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
                    Text('• Specialization / Experience: $experience', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('• Workplace / Link: $socialLink', style: const TextStyle(fontSize: 12)),
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
                  'message': 'Your advisor verification request was not approved. Please resubmit valid credentials.',
                  'category': 'Verification',
                  'targetRole': 'advisor',
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
                'role': 'advisor',
                'verificationStatus': 'approved',
              });
              await FirebaseFirestore.instance.collection('verificationRequests').doc(uid).set({
                'status': 'approved',
              }, SetOptions(merge: true));

              try {
                await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').add({
                  'title': 'Credentials Approved! 🎉',
                  'message': 'Congratulations! Your credentials have been verified and approved by the admin. You can now publish safety guidance protocols.',
                  'category': 'Verification',
                  'targetRole': 'advisor',
                  'timestamp': FieldValue.serverTimestamp(),
                  'isRead': false,
                });
              } catch (_) {}

              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name approved as Healthcare Advisor!')),
                );
              }
            },
            child: const Text('Approve Advisor'),
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
              .where('role', isEqualTo: 'advisor')
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            final totalAdvisors = docs.length;
            final approvedAdvisors = docs.where((a) => a['verificationStatus'] == 'approved').length;
            final pendingAdvisors = docs.where((a) => a['verificationStatus'] == 'pending' || a['verificationStatus'] == 'none').length;
            final rejectedAdvisors = docs.where((a) => a['verificationStatus'] == 'rejected').length;

            var filtered = docs;
            if (_statusFilter != 'All Status') {
              filtered = filtered.where((a) {
                final st = (a['verificationStatus'] ?? 'pending').toString().toLowerCase();
                return st == _statusFilter.toLowerCase();
              }).toList();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Healthcare Advisors', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          _Badge(text: '• $approvedAdvisors Active', color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Manage health advisors, clinical credentials, and verification statuses in real-time.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),

                      // Summary Cards (Clickable Tabs)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'All Status'),
                              child: _SummaryBox(title: 'TOTAL', value: '$totalAdvisors', tag: 'Advisors', color: AppColors.brandTeal, isSelected: _statusFilter == 'All Status'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'Approved'),
                              child: _SummaryBox(title: 'APPROVED', value: '$approvedAdvisors', tag: 'Verified', color: AppColors.success, isSelected: _statusFilter == 'Approved'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'Pending'),
                              child: _SummaryBox(title: 'PENDING', value: '$pendingAdvisors', tag: 'Review', color: AppColors.warning, isSelected: _statusFilter == 'Pending'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = 'Rejected'),
                              child: _SummaryBox(title: 'REJECTED', value: '$rejectedAdvisors', tag: 'Closed', color: AppColors.danger, isSelected: _statusFilter == 'Rejected'),
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
                            child: Text('No Healthcare Advisors found for this filter.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((a) {
                          final name = a['name'] ?? 'Healthcare Advisor';
                          final email = a['email'] ?? '';
                          final uid = a['id'] ?? a['uid'] ?? '';
                          final status = a['verificationStatus'] ?? 'pending';
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
                                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
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
                                        child: const Text('⚕ Clinical Advisor', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.info)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPending ? AppColors.brandTeal : Colors.white,
                                          foregroundColor: isPending ? Colors.white : AppColors.brandTeal,
                                          minimumSize: const Size(110, 28),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          side: isPending ? BorderSide.none : const BorderSide(color: AppColors.brandTeal),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _showReviewDialog(context, a),
                                        child: Text(isPending ? 'Review Credentials' : 'Credentials 📄', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      // FitPulse Verification Engine Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                        child: const Row(
                          children: [
                            Icon(Icons.security, color: AppColors.brandTeal, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('FitPulse Verification Engine', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                  SizedBox(height: 2),
                                  Text('Medical licensing integration connected to Firestore real-time DB.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                                ],
                              ),
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
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
