import 'package:flutter/cupertino.dart';

import '../../../services/sharedpref.dart';
import '../../../services/cache_service.dart';
import '../Repository.dart';
import '../model/workout_history_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository repo;

  DashboardViewModel(this.repo);

  Map<String, dynamic>? data;
  List<WorkoutHistoryModel> workoutHistory = [];
  bool isLoading = false;
  String? error;
  int progress = 0;
  int streak = 0;

  int get workoutCount => workoutHistory.length;

  int get totalDurationMinutes =>
      workoutHistory.fold(0, (sum, w) => sum + w.durationSeconds) ~/ 60;

  /// Calculates the current consecutive-day workout streak.
  /// Respects the user's customizable rest days per week setting.
  int _calculateStreak(List<WorkoutHistoryModel> history) {
    if (history.isEmpty) return 0;

    final restDaysPerWeek = data?['rest_days_per_week'] as int? ?? 4;

    // Collect unique workout dates (calendar days only)
    final workoutDays = <DateTime>{};
    for (final w in history) {
      workoutDays.add(DateTime(w.date.year, w.date.month, w.date.day));
    }

    final sortedDates = workoutDays.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final mostRecent = sortedDates.first;
    final gapToToday = todayDate.difference(mostRecent).inDays;

    if (gapToToday > restDaysPerWeek) {
      return 0; // Streak is broken
    }

    DateTime startDate = mostRecent;
    DateTime prevDate = mostRecent;

    for (int i = 1; i < sortedDates.length; i++) {
      final currentDate = sortedDates[i];
      final gap = prevDate.difference(currentDate).inDays - 1;

      if (gap <= restDaysPerWeek) {
        startDate = currentDate;
        prevDate = currentDate;
      } else {
        break; // Streak broke here
      }
    }

    final endDate = todayDate.isBefore(mostRecent) ? mostRecent : todayDate;
    return endDate.difference(startDate).inDays + 1;
  }

  Future<void> load(String userId) async {
    final cached = CacheService.get('dashboard_data_$userId');
    if (cached != null) {
      try {
        final cachedData = cached['data'] as Map<String, dynamic>?;
        final cachedHistory = cached['workoutHistory'] as List<dynamic>?;
        final cachedProgress = cached['progress'] as int?;

        if (cachedData != null) {
          data = cachedData;
        }
        if (cachedHistory != null) {
          workoutHistory = cachedHistory
              .map((e) => WorkoutHistoryModel.fromCacheMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        if (cachedProgress != null) {
          progress = cachedProgress;
        }
        streak = _calculateStreak(workoutHistory);
        isLoading = false;
        error = null;
        notifyListeners();
      } catch (e) {
        print("Error restoring dashboard cache: $e");
      }
    } else {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait<dynamic>([
        repo.getDashboardData(userId),
        repo.getWorkoutHistory(userId),
        repo.getTrackedProgress(userId),
      ]);
      data = results[0] as Map<String, dynamic>?;
      workoutHistory = results[1] as List<WorkoutHistoryModel>;
      progress = results[2] as int;
      streak = _calculateStreak(workoutHistory);
      error = null;

      await CacheService.put('dashboard_data_$userId', {
        'data': data,
        'workoutHistory': workoutHistory.map((e) => e.toCacheMap()).toList(),
        'progress': progress,
      });
    } catch (e) {
      print("Error loading dashboard from network: $e");
      if (data == null) {
        error = "Failed to load data";
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repo.logout();
    await sharedprefs().clearUserId();
  }
}