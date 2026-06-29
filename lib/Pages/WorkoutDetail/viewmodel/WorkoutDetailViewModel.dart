import 'package:flutter/foundation.dart';
import 'package:flex_fit/Pages/Dashboard/Repository.dart';
import 'package:flex_fit/Pages/Dashboard/model/workout_detail_model.dart';
import 'package:flex_fit/Pages/Dashboard/model/workout_history_model.dart';
import 'package:flex_fit/services/cache_service.dart';

class WorkoutDetailViewModel extends ChangeNotifier {
  final DashboardRepository _repo;
  WorkoutSessionDetail? detail;
  bool isLoading = false;
  String? error;

  WorkoutDetailViewModel(this._repo);

  Future<void> loadDetail(WorkoutHistoryModel workout) async {
    final cacheKey = 'workout_detail_${workout.id}';
    final cached = CacheService.get(cacheKey);

    if (cached != null) {
      try {
        detail = WorkoutSessionDetail.fromMap(Map<String, dynamic>.from(cached));
        isLoading = false;
        error = null;
        notifyListeners();
      } catch (e) {
        print("Error restoring workout detail cache: $e");
      }
    } else {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final rawData = await _repo.getWorkoutDetailRaw(workout.id);
      detail = WorkoutSessionDetail.fromMap(rawData);
      error = null;
      await CacheService.put(cacheKey, rawData);
    } catch (e) {
      print("Error loading workout detail from network: $e");
      if (detail == null) {
        error = "Failed to load workout details.";
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
