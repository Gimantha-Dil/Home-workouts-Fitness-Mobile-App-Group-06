import 'user_role.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String category; // System, Workout, Verification, Safety, Reminder
  final UserRole targetRole;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    required this.targetRole,
    this.isRead = false,
  });
}
