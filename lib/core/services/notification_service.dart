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
    if (_initialized) return;

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

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    _initialized = true;
    debugPrint('🔔 NotificationService initialized successfully.');
  }

  /// Request POST_NOTIFICATIONS permission on Android 13+ / iOS
  Future<bool> requestPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  /// Schedule a weekly repeating reminder
  Future<void> scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required int hour,
    required int minute,
    bool soundOn = true,
  }) async {
    if (!_initialized) await init();

    final channelId = soundOn ? channelSoundId : channelSilentId;
    final channelName = soundOn ? 'Reminders (Sound On)' : 'Reminders (Silent)';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Scheduled workout reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundOn,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfDayAndTime(dayOfWeek, hour, minute);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule weekly reminder: $e');
    }
  }

  /// Schedule daily streak alert at 20:00
  Future<void> scheduleStreakAlert({
    bool soundOn = true,
    String title = 'Streak Alert!',
    String body = 'Keep your streak going! Complete your workout for today.',
  }) async {
    if (!_initialized) await init();

    const streakAlertId = 88888;
    final channelId = soundOn ? channelSoundId : channelSilentId;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Streak Alerts',
      channelDescription: 'Daily streak preservation alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: soundOn,
    );

    final scheduledDate = _nextInstanceOfTime(20, 0);

    try {
      await _notificationsPlugin.zonedSchedule(
        streakAlertId,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule streak alert: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
