import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class ManagedUser {
  final String id;
  String name;
  String email;
  String role;
  String detail;
  String status;
  Color statusColor;

  ManagedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.detail,
    required this.status,
    required this.statusColor,
  });
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedRoleFilter = 'All Roles';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<ManagedUser> _users = [
    ManagedUser(id: '#U001', name: 'Nethmi Silva', email: 'nethmi@gmail.com', role: 'Customer', detail: 'Joined Apr 24', status: 'Active', statusColor: AppColors.success),
    ManagedUser(id: '#U002', name: 'Kasun Perera', email: 'kasun@gmail.com', role: 'Customer', detail: 'Joined Apr 22', status: 'Active', statusColor: AppColors.success),
    ManagedUser(id: '#U003', name: 'Sanduni Fernando', email: 'sanduni@gmail.com', role: 'Customer', detail: 'Joined Apr 20', status: 'Active', statusColor: AppColors.success),
    ManagedUser(id: '#U004', name: 'Tharindu Wijesinghe', email: 'tharindu@gmail.com', role: 'Trainer', detail: '32 Trainees', status: 'Active', statusColor: AppColors.success),
    ManagedUser(id: '#U005', name: 'Kavindi Jayalath', email: 'kavindi@gmail.com', role: 'Advisor', detail: 'Verified MD', status: 'Active', statusColor: AppColors.success),
    ManagedUser(id: '#U006', name: 'Ruwan Perera', email: 'ruwan@gmail.com', role: 'Customer', detail: 'Paused sub', status: 'Inactive', statusColor: AppColors.danger),
  ];

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String newRole = 'Customer';

    showDialog(
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
                items: const ['Customer', 'Trainer', 'Advisor', 'Admin']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
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
              onPressed: () {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                if (name.isNotEmpty && email.isNotEmpty) {
                  setState(() {
                    _users.insert(
                      0,
                      ManagedUser(
                        id: '#U0${_users.length + 1}',
                        name: name,
                        email: email,
                        role: newRole,
                        detail: 'Joined Just Now',
                        status: 'Active',
                        statusColor: AppColors.success,
                      ),
                    );
                  });
                  Navigator.of(ctx).pop();
                  _showSnack('User "$name" added successfully!');
                }
              },
              child: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openUserActions(ManagedUser u) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage ${u.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${u.email} • ${u.id}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(u.status == 'Active' ? Icons.block : Icons.check_circle_outline, color: u.status == 'Active' ? AppColors.danger : AppColors.success),
              title: Text(u.status == 'Active' ? 'Deactivate User Account' : 'Activate User Account', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() {
                  u.status = u.status == 'Active' ? 'Inactive' : 'Active';
                  u.statusColor = u.status == 'Active' ? AppColors.success : AppColors.danger;
                });
                Navigator.of(ctx).pop();
                _showSnack('${u.name} status set to ${u.status}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Remove User from Platform', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger)),
              onTap: () {
                setState(() {
                  _users.removeWhere((item) => item.id == u.id);
                });
                Navigator.of(ctx).pop();
                _showSnack('${u.name} removed from platform');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ManagedUser> filtered = _users;

    // Filter by Dropdown
    if (_selectedRoleFilter != 'All Roles') {
      filtered = filtered.where((u) => u.role.toLowerCase() == _selectedRoleFilter.toLowerCase().replaceAll('s', '')).toList();
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.id.toLowerCase().contains(q)).toList();
    }

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
          children: const [
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('User Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _Badge(text: '• LIVE DB', color: AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Review, verify and moderate all registered platform users.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),

                  // Summary Badges
                  Row(
                    children: [
                      Expanded(child: _SummaryBox(title: 'TOTAL', value: '${_users.length}', tag: '+12%', color: AppColors.brandTeal)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'ACTIVE', value: '${_users.where((u) => u.status == 'Active').length}', tag: '94%', color: AppColors.success)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryBox(title: 'PENDING', value: '${_users.where((u) => u.status == 'Inactive').length}', tag: '0.3%', color: AppColors.warning)),
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

                  // User List
                  if (filtered.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No matching users found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    )
                  else
                    ...filtered.map((u) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.brandTeal.withOpacity(0.12),
                                child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(width: 4),
                                        Text(u.id, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text(u.email, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _Badge(text: u.role, color: AppColors.brandTeal),
                                        const SizedBox(width: 6),
                                        Text(u.detail, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                        const Spacer(),
                                        _Badge(text: '• ${u.status}', color: u.statusColor),
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
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
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
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
