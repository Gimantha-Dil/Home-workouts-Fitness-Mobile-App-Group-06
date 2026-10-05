import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../models/user_role.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _streakAlertsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get streakAlertsEnabled => _streakAlertsEnabled;

  final List<NotificationModel> _notifications = [
    // Customer Notifications
    NotificationModel(
      id: 'n_c1',
      title: '7-Day Workout Streak!',
      message: 'Great job! You reached your 7-day consistency goal today.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      category: 'Reminder',
      targetRole: UserRole.customer,
      isRead: false,
    ),
    NotificationModel(
      id: 'n_c2',
      title: 'New Routine Assigned',
      message: 'Alex Carter added "Full Body Beginner II" to your queue.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Workout',
      targetRole: UserRole.customer,
      isRead: false,
    ),
    NotificationModel(
      id: 'n_c3',
      title: 'Clinical Safety Tip',
      message: 'Remember to complete your 6-minute warm-up before resistance training.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'Safety',
      targetRole: UserRole.customer,
      isRead: true,
    ),

    // Trainer Notifications
    NotificationModel(
      id: 'n_t1',
      title: 'Workout Approved!',
      message: 'Your routine "Lower Body Power" was accredited by Dr. Silva.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      category: 'Verification',
      targetRole: UserRole.trainer,
      isRead: false,
    ),
    NotificationModel(
      id: 'n_t2',
      title: 'New Trainee Check-in',
      message: 'Nethmi Silva completed day 4 of Full Body Beginner.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      category: 'Workout',
      targetRole: UserRole.trainer,
      isRead: false,
    ),

    // Advisor Notifications
    NotificationModel(
      id: 'n_a1',
      title: 'New Protocol Verification Request',
      message: 'Review requested for "Cardio & Heart Rate Zones v2".',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      category: 'Verification',
      targetRole: UserRole.advisor,
      isRead: false,
    ),
    NotificationModel(
      id: 'n_a2',
      title: 'Clinical Guideline Update',
      message: 'ACSM 2026 heart rate thresholds updated in system library.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      category: 'Safety',
      targetRole: UserRole.advisor,
      isRead: true,
    ),

    // Admin Notifications
    NotificationModel(
      id: 'n_adm1',
      title: 'System Telemetry Alert',
      message: 'Server Node-01 database response latency normal (14ms).',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      category: 'System',
      targetRole: UserRole.admin,
      isRead: false,
    ),
    NotificationModel(
      id: 'n_adm2',
      title: 'Pending Trainer Accreditation Queue',
      message: '3 certified fitness trainers submitted liability certifications.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      category: 'Verification',
      targetRole: UserRole.admin,
      isRead: false,
    ),
  ];

  List<NotificationModel> getNotificationsForRole(UserRole role) {
    if (!_notificationsEnabled) return [];
    return _notifications.where((n) => n.targetRole == role).toList();
  }

  int getUnreadCountForRole(UserRole role) {
    if (!_notificationsEnabled) return 0;
    return _notifications.where((n) => n.targetRole == role && !n.isRead).length;
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleSound(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  void toggleStreakAlerts(bool value) {
    _streakAlertsEnabled = value;
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsReadForRole(UserRole role) {
    for (var n in _notifications) {
      if (n.targetRole == role) {
        n.isRead = true;
      }
    }
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required String category,
    required UserRole targetRole,
  }) {
    _notifications.insert(
      0,
      NotificationModel(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        category: category,
        targetRole: targetRole,
        isRead: false,
      ),
    );
    notifyListeners();
  }
}
