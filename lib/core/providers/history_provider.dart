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
