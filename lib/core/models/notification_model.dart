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

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? category,
    UserRole? targetRole,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      targetRole: targetRole ?? this.targetRole,
      isRead: isRead ?? this.isRead,
    );
  }
}
