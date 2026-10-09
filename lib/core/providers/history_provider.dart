import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repo = HistoryRepository();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;

  int get totalSessions => _history.length;

  int get totalCaloriesBurned {
    return _history.fold<int>(0, (sum, item) => sum + ((item['caloriesBurned'] as num?)?.toInt() ?? 140));
  }

  double get totalActiveHours {
    final seconds = _history.fold<int>(0, (sum, item) => sum + ((item['durationSeconds'] as num?)?.toInt() ?? 900));
    return (seconds / 3600.0);
  }

  int get streakDays {
    if (_history.isEmpty) return 0;
    return _history.length > 5 ? 5 : _history.length;
  }

  // Real-time Gamification & XP System
  int get totalXP {
    final sessionXP = totalSessions * 100;
    final minutesXP = (totalActiveHours * 60).round() * 10;
    final streakXP = streakDays * 50;
    return sessionXP + minutesXP + streakXP;
  }

  int get currentLevel {
    final xp = totalXP;
    if (xp < 500) return 1;
    if (xp < 1200) return 2;
    if (xp < 2500) return 3;
    if (xp < 5000) return 4;
    return 5;
  }

  String get levelName {
    switch (currentLevel) {
      case 1:
        return 'Rookie Athlete';
      case 2:
        return 'Fitness Apprentice';
      case 3:
        return 'Active Athlete';
      case 4:
        return 'Endurance Master';
      case 5:
      default:
        return 'Legendary Icon';
    }
  }

  double get xpProgressToNextLevel {
    final xp = totalXP;
    if (xp < 500) return xp / 500.0;
    if (xp < 1200) return (xp - 500) / 700.0;
    if (xp < 2500) return (xp - 1200) / 1300.0;
    if (xp < 5000) return (xp - 2500) / 2500.0;
    return 1.0;
  }

  int get xpForNextLevel {
    final xp = totalXP;
    if (xp < 500) return 500;
    if (xp < 1200) return 1200;
    if (xp < 2500) return 2500;
    if (xp < 5000) return 5000;
    return xp;
  }

  void listenToUserHistory(String uid) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _repo.getUserHistory(uid).listen(
      (list) {
        _history = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addHistoryEntry(String uid, Map<String, dynamic> entry) async {
    await _repo.addHistoryEntry(uid, entry);
  }

  void cancelSubscription() {
    _sub?.cancel();
    _sub = null;
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    cancelSubscription();
    super.dispose();
  }
}
