import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class SafetyProtocolItem {
  final String id;
  String title;
  final String category;
  final String status;
  String desc;
  final String detail;
  final Color statusColor;

  SafetyProtocolItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.desc,
    required this.detail,
    required this.statusColor,
  });
}

class SafetyContentManagementScreen extends StatefulWidget {
  const SafetyContentManagementScreen({super.key});

  @override
  State<SafetyContentManagementScreen> createState() => _SafetyContentManagementScreenState();
}

class _SafetyContentManagementScreenState extends State<SafetyContentManagementScreen> {
  int _tab = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<SafetyProtocolItem> _guides = [
    SafetyProtocolItem(
      id: 'ID: S001',
      title: 'Warm-up Routine',
      status: 'Published',
      category: 'Warm-up',
      desc: 'Foundational dynamic stretches, joint mobility preparation...',
      detail: 'Updated 2d ago • 4 movements',
      statusColor: AppColors.success,
    ),
    SafetyProtocolItem(
      id: 'ID: S002',
      title: 'Cool-down Guide',
      status: 'Published',
      category: 'Cool-down',
      desc: 'Parasympathetic recovery breathing, static stretching sequences...',
      detail: 'Updated 4d ago • 5 movements',
      statusColor: AppColors.success,
    ),
    SafetyProtocolItem(
      id: 'ID: S003',
      title: 'Exercise Precautions',
      status: 'Published',
      category: 'Precautions',
      desc: 'Equipment clearance guidelines, correct lumbar support alignment...',
      detail: 'Updated 1w ago • Clinical Standard',
      statusColor: AppColors.success,
    ),
    SafetyProtocolItem(
      id: 'ID: S004',
      title: 'Warning Signs & Red Flags',
      status: 'Published',
      category: 'Safety Warning',
      desc: 'Recognizing acute dizziness, irregular heart palpitations, dehydration...',
      detail: 'Updated 2w ago • Critical Protocol',
      statusColor: AppColors.danger,
    ),
    SafetyProtocolItem(
      id: 'ID: S005',
      title: 'Health Considerations',
      status: 'Published',
      category: 'Health',
      desc: 'Guidelines for individuals with hypertension, asthma, joint replacements...',
      detail: 'Updated 1mo ago • Medical Advisory',
      statusColor: AppColors.success,
    ),
  ];

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openEditDialog(SafetyProtocolItem g) {
    final titleCtrl = TextEditingController(text: g.title);
    final descCtrl = TextEditingController(text: g.desc);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${g.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Protocol Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description / Instructions'),
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
              final newTitle = titleCtrl.text.trim();
              final newDesc = descCtrl.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() {
                  g.title = newTitle;
                  if (newDesc.isNotEmpty) g.desc = newDesc;
                });
                Navigator.of(ctx).pop();
                _showSnack('Updated protocol "${g.title}"');
              }
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _viewProtocolDetails(SafetyProtocolItem g) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${g.category} • ${g.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
            const SizedBox(height: 8),
            Text(g.desc, style: const TextStyle(fontSize: 12, height: 1.4)),
            const SizedBox(height: 8),
            Text(g.detail, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<SafetyProtocolItem> filtered = _guides;

    if (_tab == 1) {
      filtered = filtered.where((g) => g.category == 'Warm-up').toList();
    } else if (_tab == 2) {
      filtered = filtered.where((g) => g.category == 'Cool-down').toList();
    } else if (_tab == 3) {
      filtered = filtered.where((g) => g.category.contains('Precaution') || g.category.contains('Warning')).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((g) => g.title.toLowerCase().contains(q) || g.desc.toLowerCase().contains(q) || g.id.toLowerCase().contains(q)).toList();
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
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            _Badge(text: 'ADMIN', color: AppColors.brandTeal),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Safety Content\nManagement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2)),
                      _Badge(text: '• 8 Live', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Manage safety guidelines, clinical protocols, and health advisories.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),

                  // Repo Banner Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.brandTeal, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PROTOCOL ENGINE ACTIVE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                              SizedBox(height: 2),
                              Text('Clinical Standards Repo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('ACSM & Physical Therapy Protocol', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search safety content, protocols, tags...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tabs
                  Row(
                    children: [
                      Expanded(child: _tabBtn('All (${_guides.length})', 0)),
                      const SizedBox(width: 4),
                      Expanded(child: _tabBtn('Warm-up', 1)),
                      const SizedBox(width: 4),
                      Expanded(child: _tabBtn('Cool-down', 2)),
                      const SizedBox(width: 4),
                      Expanded(child: _tabBtn('Precautions', 3)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (filtered.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No safety protocols found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    )
                  else
                    ...filtered.map((g) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _Badge(text: g.category, color: AppColors.brandTeal),
                                      const SizedBox(width: 6),
                                      Text(g.id, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  _Badge(text: '• ${g.status}', color: g.statusColor),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(g.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(g.desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                              const SizedBox(height: 6),
                              Text(g.detail, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () => _viewProtocolDetails(g)),
                                  IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () => _openEditDialog(g)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                    onPressed: () {
                                      setState(() => _guides.removeWhere((item) => item.id == g.id));
                                      _showSnack('${g.title} deleted.');
                                    },
                                  ),
                                ],
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

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
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
