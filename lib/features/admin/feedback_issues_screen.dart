import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class FeedbackItem {
  final String id;
  final String type; // Feedback or Issue
  String status; // Resolved, Open, In Progress
  final String body;
  final String user;
  final String date;
  final Color typeColor;
  Color statusColor;

  FeedbackItem({
    required this.id,
    required this.type,
    required this.status,
    required this.body,
    required this.user,
    required this.date,
    required this.typeColor,
    required this.statusColor,
  });
}

class FeedbackIssuesScreen extends StatefulWidget {
  const FeedbackIssuesScreen({super.key});

  @override
  State<FeedbackIssuesScreen> createState() => _FeedbackIssuesScreenState();
}

class _FeedbackIssuesScreenState extends State<FeedbackIssuesScreen> {
  int _tab = 0; // 0: All, 1: Feedback, 2: Issues
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<FeedbackItem> _items = [
    FeedbackItem(
      id: '#F001',
      type: 'Feedback',
      status: 'Resolved',
      body: 'Great app! Keep it up! The personalized workout suggestions helped a lot.',
      user: 'Nethmi Silva • Pro Plan',
      date: 'Apr 28',
      typeColor: AppColors.brandTeal,
      statusColor: AppColors.success,
    ),
    FeedbackItem(
      id: '#I002',
      type: 'Issue',
      status: 'Open',
      body: 'Video not loading on step 3 of HIIT Cardio Routine',
      user: 'Kasun Perera • iOS 17.4',
      date: 'Apr 26',
      typeColor: AppColors.danger,
      statusColor: AppColors.warning,
    ),
    FeedbackItem(
      id: '#F003',
      type: 'Feedback',
      status: 'Resolved',
      body: 'Very helpful content and clean UI. The rest timer is super intuitive.',
      user: 'Sanduni Fernando • Trial User',
      date: 'Apr 24',
      typeColor: AppColors.brandTeal,
      statusColor: AppColors.success,
    ),
    FeedbackItem(
      id: '#I004',
      type: 'Issue',
      status: 'In Progress',
      body: 'Incorrect workout data calculation after apple health sync',
      user: 'Tharindu Wijesinghe • Watch v9',
      date: 'Apr 22',
      typeColor: AppColors.danger,
      statusColor: AppColors.info,
    ),
    FeedbackItem(
      id: '#F005',
      type: 'Feedback',
      status: 'Resolved',
      body: 'Love the safety tips section before high intensity lifts!',
      user: 'Kavindi Jayalath • Pro Member',
      date: 'Apr 20',
      typeColor: AppColors.brandTeal,
      statusColor: AppColors.success,
    ),
  ];

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openReplyDialog(FeedbackItem item) {
    final replyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to ${item.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${item.user}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('"${item.body}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            TextField(
              controller: replyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your official support response...',
                border: OutlineInputBorder(),
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
            onPressed: () {
              final text = replyCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(ctx).pop();
                _showSnack('Official reply sent to ${item.user}!');
              }
            },
            child: const Text('Send Reply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _toggleResolve(FeedbackItem item) {
    setState(() {
      if (item.status == 'Resolved') {
        item.status = 'Open';
        item.statusColor = AppColors.warning;
      } else {
        item.status = 'Resolved';
        item.statusColor = AppColors.success;
      }
    });
    _showSnack('Ticket ${item.id} status set to ${item.status}');
  }

  @override
  Widget build(BuildContext context) {
    List<FeedbackItem> filtered = _items;

    // Tab Filter
    if (_tab == 1) {
      filtered = filtered.where((item) => item.type == 'Feedback').toList();
    } else if (_tab == 2) {
      filtered = filtered.where((item) => item.type == 'Issue').toList();
    }

    // Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((item) => item.body.toLowerCase().contains(q) || item.user.toLowerCase().contains(q) || item.id.toLowerCase().contains(q)).toList();
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
                      Text('Feedback & Issues', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('Updated just now', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Review user feedback, bug reports, and customer satisfaction.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search feedback, customer, or issue ID...',
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
                  const SizedBox(height: 16),

                  // Tabs
                  Row(
                    children: [
                      Expanded(child: _tabBtn('All (${_items.length})', 0)),
                      const SizedBox(width: 8),
                      Expanded(child: _tabBtn('Feedback (${_items.where((i) => i.type == 'Feedback').length})', 1)),
                      const SizedBox(width: 8),
                      Expanded(child: _tabBtn('Issues (${_items.where((i) => i.type == 'Issue').length})', 2)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (filtered.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No feedback or issues found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    )
                  else
                    ...filtered.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(item.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                                      const SizedBox(width: 6),
                                      _Badge(text: item.type, color: item.typeColor),
                                    ],
                                  ),
                                  _Badge(text: '• ${item.status}', color: item.statusColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('"${item.body}"', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary, height: 1.3)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.user, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  Text(item.date, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(60, 28),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _openReplyDialog(item),
                                    child: const Text('Reply', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: item.status == 'Resolved' ? AppColors.info : AppColors.brandTeal,
                                      minimumSize: const Size(60, 28),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _toggleResolve(item),
                                    child: Text(item.status == 'Resolved' ? 'Re-open' : 'Resolve', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
