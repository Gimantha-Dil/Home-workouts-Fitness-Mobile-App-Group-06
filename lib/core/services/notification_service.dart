import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String channelSoundId = 'reminders_sound';
  static const String channelSilentId = 'reminders_silent';

  /// Initialize Local Notifications and Timezone
  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Timezone initialization note: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );
      _initialized = true;
      debugPrint('🔔 NotificationService Initialized Successfully');
    } catch (e) {
      debugPrint('Notification init exception: $e');
    }
  }

  /// Request Notification Permissions
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (_) {}
    return true;
  }

  /// Show immediate Notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool soundOn = true,
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          soundOn ? channelSoundId : channelSilentId,
          soundOn ? 'Reminders with Sound' : 'Silent Reminders',
          channelDescription: 'Workout reminder alerts',
          importance: soundOn ? Importance.high : Importance.defaultImportance,
          priority: soundOn ? Priority.high : Priority.defaultPriority,
          playSound: soundOn,
          enableVibration: soundOn,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: soundOn,
        ),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
      );
      debugPrint('🔔 Showed Immediate Notification #$id: $title');
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
    }
  }

  /// Schedule a Weekly Repeating Workout Reminder
  Future<void> scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // 1 = Mon, 7 = Sun
    required int hour,
    required int minute,
    bool soundOn = true,
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      final scheduledDate = _nextInstanceOfDayTime(dayOfWeek, hour, minute);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          soundOn ? channelSoundId : channelSilentId,
          soundOn ? 'Reminders with Sound' : 'Silent Reminders',
          channelDescription: 'Scheduled workout reminder alerts',
          importance: soundOn ? Importance.high : Importance.defaultImportance,
          priority: soundOn ? Priority.high : Priority.defaultPriority,
          playSound: soundOn,
          enableVibration: soundOn,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: soundOn,
        ),
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      debugPrint('⏰ Scheduled Reminder #$id for $title at ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  /// Schedule 2-Day Inactivity Nudge
  Future<void> scheduleInactivityNudge() async {
    if (kIsWeb || !_initialized) return;

    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(days: 2));
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelSoundId,
          'Reminders with Sound',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        99999,
        'FitPulse: We miss your energy!',
        'You\'ve been inactive for 2 days. A quick 10-minute session keeps your momentum alive!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  /// Schedule Daily Streak Alert
  Future<void> scheduleStreakAlert({bool soundOn = true}) async {
    if (kIsWeb || !_initialized) return;

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0); // 8:00 PM
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          soundOn ? channelSoundId : channelSilentId,
          soundOn ? 'Reminders with Sound' : 'Silent Reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: soundOn,
        ),
        iOS: DarwinNotificationDetails(presentSound: soundOn),
      );

      await _notificationsPlugin.zonedSchedule(
        88888,
        'FitPulse: Keep Your Streak Alive! 🔥',
        'Complete today\'s quick routine before midnight to protect your active streak!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  /// Cancel specific notification ID
  Future<void> cancel(int id) async {
    if (kIsWeb || !_initialized) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  /// Helper to calculate the next occurrence of dayOfWeek and time
  tz.TZDateTime _nextInstanceOfDayTime(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
