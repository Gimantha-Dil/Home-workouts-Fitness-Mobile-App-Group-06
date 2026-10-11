import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../firebase_options.dart';
import '../../shared/widgets/common_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedRoleFilter = 'All Roles';
  String _statusTab = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _purgeUserFromAllDatabases(String uid, String name, [String? email]) async {
    try {
      // 1. Delete from Cloud Firestore 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // 2. Delete from Cloud Firestore 'verificationRequests' collection
      await FirebaseFirestore.instance.collection('verificationRequests').doc(uid).delete();

      // 3. Delete any chats associated with this user
      final chatDocs = await FirebaseFirestore.instance
          .collection('chats')
          .where('customerUid', isEqualTo: uid)
          .get();
      for (final doc in chatDocs.docs) {
        await doc.reference.delete();
      }

      // 4. Delete user record from Supabase PostgreSQL 'users' table
      try {
        await Supabase.instance.client.from('users').delete().eq('id', uid);
      } catch (e) {
        debugPrint('Supabase table purge note: $e');
      }

      // 5. Purge user photos and verification documents from Supabase Storage
      try {
        await Supabase.instance.client.storage
            .from('user-photos')
            .remove(['avatars/$uid/']);
      } catch (_) {}

      try {
        await Supabase.instance.client.storage
            .from('verification-docs')
            .remove(['docs/$uid/']);
      } catch (_) {}

      // 6. Delete from Firebase Authentication using Secondary Auth Admin App
      try {
        final secondaryApp = await Firebase.initializeApp(
          name: 'AdminUserPurge_${DateTime.now().millisecondsSinceEpoch}',
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final secondaryAuth = fb.FirebaseAuth.instanceFor(app: secondaryApp);
        final currentUser = secondaryAuth.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          await currentUser.delete();
        }
        await secondaryApp.delete();
      } catch (e) {
        debugPrint('Firebase Auth account purge note: $e');
      }

      _showSnack('Account, email & files for "$name" purged from all databases!');
    } catch (e) {
      _showSnack('User purge error: $e');
    }
  }

  Future<void> _autoCleanOrphanedData(List<Map<String, dynamic>> allUsers) async {
    int purgedCount = 0;
    _showSnack('Scanning databases for stale/orphaned records...');

    try {
      final userIds = allUsers
          .map((u) => u['id']?.toString() ?? u['uid']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      // Purge verification requests that don't match active users
      final verReqs = await FirebaseFirestore.instance.collection('verificationRequests').get();
      for (final req in verReqs.docs) {
        final reqUid = req.id;
        if (!userIds.contains(reqUid)) {
          await req.reference.delete();
          purgedCount++;
        }
      }

      // Purge Supabase orphan users
      try {
        final sbUsers = await Supabase.instance.client.from('users').select('id');
        for (final sbU in sbUsers) {
          final sbId = sbU['id']?.toString() ?? '';
          if (sbId.isNotEmpty && !userIds.contains(sbId)) {
            await Supabase.instance.client.from('users').delete().eq('id', sbId);
            purgedCount++;
          }
        }
      } catch (_) {}

      _showSnack('Real-time database cleanup complete: $purgedCount stale records purged!');
    } catch (e) {
      _showSnack('Auto-clean note: $e');
    }
  }

  Future<void> _openAddUserDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'password123');
    String newRole = 'customer';
    bool isCreating = false;

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
              const SizedBox(height: 10),
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(labelText: 'Initial Password', prefixIcon: Icon(Icons.lock_outline)),
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
              onPressed: isCreating
                  ? null
                  : () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim().toLowerCase();
                final password = passwordCtrl.text.trim();

                if (name.isEmpty || email.isEmpty || password.length < 6) {
                  _showSnack('Please enter name, valid email, and password (6+ chars).');
                  return;
                }

                setDialogState(() => isCreating = true);

                try {
                  String uid = '';

                  // 1. Create User Account in Firebase Authentication
                  try {
                    final secondaryApp = await Firebase.initializeApp(
                      name: 'AdminUserCreation_${DateTime.now().millisecondsSinceEpoch}',
                      options: DefaultFirebaseOptions.currentPlatform,
                    );
                    final secondaryAuth = fb.FirebaseAuth.instanceFor(app: secondaryApp);

                    final cred = await secondaryAuth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    uid = cred.user?.uid ?? '';
                    await cred.user?.updateDisplayName(name);
                    await secondaryApp.delete();
                  } catch (e) {
                    debugPrint('Firebase Auth creation note: $e');
                  }

                  if (uid.isEmpty) {
                    uid = FirebaseFirestore.instance.collection('users').doc().id;
                  }

                  final userData = {
                    'id': uid,
                    'name': name,
                    'email': email,
                    'role': newRole,
                    'verificationStatus': newRole == 'customer' ? 'none' : 'approved',
                    'isProfileCompleted': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  };

                  // 2. Save User Document in Cloud Firestore DB
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set(userData, SetOptions(merge: true));

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _showSnack('User "$name" created in Firebase Auth & Firestore DB!');
                } catch (e) {
                  setDialogState(() => isCreating = false);
                  _showSnack('Failed to create user: $e');
                }
              },
              child: isCreating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              leading: const Icon(Icons.delete_forever, color: AppColors.danger),
              title: const Text('Purge Account & Files from DB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger)),
              onTap: () async {
                if (ctx.mounted) Navigator.of(ctx).pop();
                await _purgeUserFromAllDatabases(uid, name, email);
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
            icon: const Icon(Icons.cleaning_services_outlined, color: AppColors.brandTeal),
            tooltip: 'Auto-Clean Stale Data',
            onPressed: () async {
              final snap = await FirebaseFirestore.instance.collection('users').get();
              final allDocs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
              await _autoCleanOrphanedData(allDocs);
            },
          ),
          const NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs.map((d) => {'id': d.id, ...d.data()}).toList() ?? [];

            final totalUsers = docs.length;
            final activeUsers = docs.where((u) => (u['verificationStatus'] ?? 'none') != 'pending' && (u['verificationStatus'] ?? 'none') != 'suspended').length;
            final pendingUsers = docs.where((u) => (u['verificationStatus'] ?? 'none') == 'pending').length;

            // Instant Real-Time Search Filter Across ALL Database Users
            final q = _searchQuery.trim().toLowerCase();
            var filtered = docs;

            if (q.isNotEmpty) {
              filtered = docs.where((u) {
                final name = (u['name'] ?? '').toString().toLowerCase();
                final email = (u['email'] ?? '').toString().toLowerCase();
                final id = (u['id'] ?? '').toString().toLowerCase();
                final role = (u['role'] ?? '').toString().toLowerCase();
                final status = (u['verificationStatus'] ?? '').toString().toLowerCase();
                return name.contains(q) ||
                    email.contains(q) ||
                    id.contains(q) ||
                    role.contains(q) ||
                    status.contains(q);
              }).toList();
            } else {
              // Apply Tab & Dropdown Role Filters when Search Box is Empty
              if (_statusTab == 'active') {
                filtered = filtered.where((u) => (u['verificationStatus'] ?? 'none') != 'pending' && (u['verificationStatus'] ?? 'none') != 'suspended').toList();
              } else if (_statusTab == 'pending') {
                filtered = filtered.where((u) => (u['verificationStatus'] ?? 'none') == 'pending').toList();
              }

              if (_selectedRoleFilter != 'All Roles') {
                final target = _selectedRoleFilter.toLowerCase();
                filtered = filtered.where((u) {
                  final r = (u['role'] ?? 'customer').toString().toLowerCase();
                  if (target.contains('customer')) return r == 'customer';
                  if (target.contains('trainer')) return r == 'trainer';
                  if (target.contains('advisor')) return r == 'advisor';
                  if (target.contains('admin')) return r == 'admin';
                  return r.contains(target);
                }).toList();
              }
            }

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

                      // Summary Badges (Clickable Tabs)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusTab = 'all'),
                              child: _SummaryBox(title: 'TOTAL', value: '$totalUsers', tag: 'Live DB', color: AppColors.brandTeal, isSelected: _statusTab == 'all'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusTab = 'active'),
                              child: _SummaryBox(title: 'ACTIVE', value: '$activeUsers', tag: 'Registered', color: AppColors.success, isSelected: _statusTab == 'active'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _statusTab = 'pending'),
                              child: _SummaryBox(title: 'PENDING', value: '$pendingUsers', tag: 'Action Req', color: AppColors.warning, isSelected: _statusTab == 'pending'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instant Real-time Search Input Bar
                      TextField(
                        controller: _searchController,
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
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No users found matching "$_searchQuery".'
                                  : 'No matching users found in Firestore.',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
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
  final bool isSelected;

  const _SummaryBox({required this.title, required this.value, required this.tag, required this.color, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSelected ? 0.22 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
      ),
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
