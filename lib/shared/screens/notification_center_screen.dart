import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/notification_model.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  int _filterTab = 0; // 0: All, 1: Unread, 2: System, 3: Reminders

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Workout':
        return Icons.fitness_center;
      case 'Safety':
        return Icons.health_and_safety_outlined;
      case 'Verification':
        return Icons.verified_user_outlined;
      case 'System':
        return Icons.tune;
      case 'Reminder':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Workout':
        return AppColors.brandTeal;
      case 'Safety':
        return AppColors.danger;
      case 'Verification':
        return AppColors.purple;
      case 'System':
        return AppColors.info;
      case 'Reminder':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final role = auth.currentUser?.role ?? UserRole.customer;

    List<NotificationModel> list = notifProvider.getNotificationsForRole(role);

    if (_filterTab == 1) {
      list = list.where((n) => !n.isRead).toList();
    } else if (_filterTab == 2) {
      list = list.where((n) => n.category == 'System' || n.category == 'Verification').toList();
    } else if (_filterTab == 3) {
      list = list.where((n) => n.category == 'Reminder' || n.category == 'Workout').toList();
    }

    final unreadCount = notifProvider.getUnreadCountForRole(role);

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
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: notifProvider.notificationsEnabled ? const Color(0xFFCCFBF1) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notifProvider.notificationsEnabled ? '${role.label} Alerts' : 'Muted',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: notifProvider.notificationsEnabled ? AppColors.brandTeal : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (unreadCount > 0 && notifProvider.notificationsEnabled)
            TextButton(
              onPressed: () => notifProvider.markAllAsReadForRole(role),
              child: const Text('Mark all read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Master Notification Toggle Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: notifProvider.notificationsEnabled ? const Color(0xFFCCFBF1) : const Color(0xFFF3F4F6),
                    child: Icon(
                      notifProvider.notificationsEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                      color: notifProvider.notificationsEnabled ? AppColors.brandTeal : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notifProvider.notificationsEnabled ? 'Push Notifications Active' : 'Push Notifications Muted',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          notifProvider.notificationsEnabled ? 'Real-time alerts, streak cues & updates' : 'All live alerts are temporarily paused',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: notifProvider.notificationsEnabled,
                    activeColor: AppColors.brandTeal,
                    onChanged: (v) => notifProvider.toggleNotifications(v),
                  ),
                ],
              ),
            ),

            if (notifProvider.notificationsEnabled) ...[
              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _filterBtn('All', 0)),
                    const SizedBox(width: 6),
                    Expanded(child: _filterBtn('Unread ($unreadCount)', 1)),
                    const SizedBox(width: 6),
                    Expanded(child: _filterBtn('System', 2)),
                    const SizedBox(width: 6),
                    Expanded(child: _filterBtn('Workouts', 3)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Notification List
              Expanded(
                child: list.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 10),
                      Text('No Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('You\'re all caught up with your alerts!', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final item = list[i];
                    final color = _categoryColor(item.category);
                    final icon = _categoryIcon(item.category);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => notifProvider.markAsRead(item.id),
                        borderRadius: BorderRadius.circular(14),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: color.withValues(alpha: 0.12),
                                    child: Icon(icon, color: color, size: 20),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.danger,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary)),
                                        Text(_timeAgo(item.timestamp), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      style: TextStyle(fontSize: 11, color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notifications_off_outlined, size: 52, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('Notifications Are Turn Off', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Turn on the switch above to receive real-time alerts.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterBtn(String label, int index) {
    final active = _filterTab == index;
    return GestureDetector(
      onTap: () => setState(() => _filterTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }
}
