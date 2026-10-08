import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'admin_shell.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedRoleFilter = 'All Roles';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _openAddUserDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String newRole = 'customer';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Platform User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.alternate_email)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: newRole,
                decoration: const InputDecoration(labelText: 'User Role', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: const ['customer', 'trainer', 'advisor', 'admin']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                    .toList(),
                onChanged: (v) => setDialogState(() => newRole = v!),
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
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                if (name.isNotEmpty && email.isNotEmpty) {
                  final newDoc = FirebaseFirestore.instance.collection('users').doc();
                  await newDoc.set({
                    'id': newDoc.id,
                    'name': name,
                    'email': email,
                    'role': newRole,
                    'verificationStatus': newRole == 'customer' ? 'none' : 'approved',
                    'profileCompleted': false,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _showSnack('User "$name" created successfully in Firestore!');
                }
              },
              child: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openUserActions(Map<String, dynamic> u) {
    final uid = u['id'] ?? u['uid'] ?? '';
    final name = u['name'] ?? 'User';
    final email = u['email'] ?? '';
    final currentStatus = u['verificationStatus'] ?? 'none';
    final isInactive = currentStatus == 'inactive' || currentStatus == 'suspended';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('$email • $uid', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(isInactive ? Icons.check_circle_outline : Icons.block, color: isInactive ? AppColors.success : AppColors.danger),
              title: Text(isInactive ? 'Activate User Account' : 'Deactivate User Account', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () async {
                final newStatus = isInactive ? 'approved' : 'suspended';
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'verificationStatus': newStatus,
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack('$name status set to $newStatus');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Remove User from Platform', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger)),
              onTap: () async {
                await FirebaseFirestore.instance.collection('users').doc(uid).delete();
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnack('$name removed from Firestore');
              },
            ),
          ],
        ),
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
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            // Filter by Dropdown Role
            var filtered = docs;
            if (_selectedRoleFilter != 'All Roles') {
              final targetRole = _selectedRoleFilter.toLowerCase().replaceAll('s', '');
              filtered = filtered.where((u) {
                final r = (u['role'] ?? 'customer').toString().toLowerCase();
                return r == targetRole;
              }).toList();
            }

            // Filter by Search Query
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              filtered = filtered.where((u) {
                final name = (u['name'] ?? '').toString().toLowerCase();
                final email = (u['email'] ?? '').toString().toLowerCase();
                final id = (u['id'] ?? '').toString().toLowerCase();
                return name.contains(q) || email.contains(q) || id.contains(q);
              }).toList();
            }

            final totalUsers = docs.length;
            final activeUsers = docs.where((u) => u['verificationStatus'] != 'suspended').length;
            final pendingUsers = docs.where((u) => u['verificationStatus'] == 'pending').length;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('User Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          _Badge(text: '• LIVE DB', color: AppColors.info),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Review, verify and moderate all registered platform users in real-time.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),

                      // Summary Badges
                      Row(
                        children: [
                          Expanded(child: _SummaryBox(title: 'TOTAL', value: '$totalUsers', tag: 'Live DB', color: AppColors.brandTeal)),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryBox(title: 'ACTIVE', value: '$activeUsers', tag: 'Registered', color: AppColors.success)),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryBox(title: 'PENDING', value: '$pendingUsers', tag: 'Action Req', color: AppColors.warning)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search name, email, or user ID...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedRoleFilter,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              items: const ['All Roles', 'Customers', 'Trainers', 'Advisors']
                                  .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedRoleFilter = v!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              minimumSize: const Size(110, 42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _openAddUserDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add User', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                            child: Text('No matching users found in Firestore.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((u) {
                          final name = u['name'] ?? 'User';
                          final email = u['email'] ?? '';
                          final role = (u['role'] ?? 'customer').toString().toUpperCase();
                          final status = u['verificationStatus'] ?? 'none';
                          final uid = u['id'] ?? u['uid'] ?? '';
                          final shortId = uid.length > 8 ? uid.substring(0, 8) : uid;

                          Color statusColor = AppColors.success;
                          if (status == 'pending') statusColor = AppColors.warning;
                          if (status == 'suspended' || status == 'rejected') statusColor = AppColors.danger;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.brandTeal.withValues(alpha: 0.12),
                                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            const SizedBox(width: 4),
                                            Text('#$shortId', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Text(email, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _Badge(text: role, color: AppColors.brandTeal),
                                            const SizedBox(width: 6),
                                            Text('Status: $status', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                            const Spacer(),
                                            _Badge(text: '• $status', color: statusColor),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                                    onPressed: () => _openUserActions(u),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
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

  const _SummaryBox({required this.title, required this.value, required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
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
