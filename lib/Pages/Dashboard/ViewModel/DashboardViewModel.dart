import 'package:flutter/cupertino.dart';

import '../../../services/sharedpref.dart';
import '../Repository.dart';
import '../model/workout_history_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository repo;

  DashboardViewModel(this.repo);

  Map<String, dynamic>? data;
  List<WorkoutHistoryModel> workoutHistory = [];
  bool isLoading = false;
  String? error;

  int index = 0;

  int get workoutCount => workoutHistory.length;

  int get totalDurationMinutes =>
      workoutHistory.fold(0, (sum, w) => sum + w.durationSeconds) ~/ 60;

  Future<void> load(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        repo.getDashboardData(userId),
        repo.getWorkoutHistory(userId),
      ]);
      data = results[0] as Map<String, dynamic>?;
      workoutHistory = results[1] as List<WorkoutHistoryModel>;
    } catch (e) {
      error = "Failed to load data";
    }

    isLoading = false;
    notifyListeners();
  }

  void changeIndex(int i) {
    index = i;
    notifyListeners();
  }

  Future<void> logout() async {
    await repo.logout();
    await sharedprefs().clearUserId();
  }
}