import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/status_badge.dart';

class ManagementItem {
  final String title;
  final String subtitle;
  final String status;
  const ManagementItem({required this.title, required this.subtitle, required this.status});
}

class ManagementListScreen extends StatelessWidget {
  final String title;
  final List<ManagementItem> items;
  final IconData icon;
  final bool showApproveReject;
  final Color color;

  const ManagementListScreen({
    super.key,
    required this.title,
    required this.items,
    this.icon = Icons.list_alt,
    this.showApproveReject = false,
    this.color = AppColors.brandTeal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = items[i];
            return AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (showApproveReject && item.status == 'Pending')
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.title} request approved.')),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 20),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.title} request rejected.')),
                          ),
                        ),
                      ],
                    )
                  else
                    StatusBadge(status: item.status),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
