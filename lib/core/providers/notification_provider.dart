import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../models/user_role.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _streakAlertsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get streakAlertsEnabled => _streakAlertsEnabled;

  List<NotificationModel> _notifications = [];
  StreamSubscription? _notifSub;

  NotificationProvider() {
    _loadSettings();
    _initAuthListener();
  }

  void _initAuthListener() {
    fb.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenNotifications(user.uid);
      } else {
        _notifSub?.cancel();
        _notifications = [];
        notifyListeners();
      }
    });
  }

  void _listenNotifications(String uid) {
    _notifSub?.cancel();
    _notifSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      _notifications = snap.docs.map((d) {
        final data = d.data();
        final roleStr = data['targetRole'] ?? 'customer';
        final role = UserRole.values.firstWhere(
              (r) => r.name == roleStr,
          orElse: () => UserRole.customer,
        );

        return NotificationModel(
          id: d.id,
          title: data['title'] ?? 'Notification',
          message: data['message'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          category: data['category'] ?? 'General',
          targetRole: role,
          isRead: data['isRead'] ?? false,
        );
      }).toList();
      notifyListeners();
    }, onError: (_) {});
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _streakAlertsEnabled = prefs.getBool('streak_alerts_enabled') ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('streak_alerts_enabled', _streakAlertsEnabled);

      final user = fb.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'settings': {
            'notificationsEnabled': _notificationsEnabled,
            'soundEnabled': _soundEnabled,
            'streakAlertsEnabled': _streakAlertsEnabled,
          }
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<bool> toggleNotifications(bool val) async {
    _notificationsEnabled = val;
    notifyListeners();
    await _saveSettings();

    if (!val) {
      await NotificationService().cancelAll();
    }
    return true;
  }

  Future<void> toggleSound(bool val) async {
    _soundEnabled = val;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleStreakAlerts(bool val) async {
    _streakAlertsEnabled = val;
    notifyListeners();
    await _saveSettings();
  }

  List<NotificationModel> getNotificationsForRole(UserRole role) {
    return _notifications;
  }

  int getUnreadCount(UserRole role) {
    return _notifications.where((n) => !n.isRead).length;
  }

  int getUnreadCountForRole(UserRole role) => getUnreadCount(role);

  Future<void> markAsRead(String id) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .update({'isRead': true});
      } catch (_) {}
    }
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(UserRole role) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .get();

        for (final doc in snap.docs) {
          await doc.reference.update({'isRead': true});
        }
      } catch (_) {}
    }

    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  Future<void> markAllAsReadForRole(UserRole role) => markAllAsRead(role);

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }
}
