import 'dart:io';
import 'package:flutter/material.dart';
import '../../Social/SocialRepository.dart';
import '../ProfileRepository.dart';
import '../model/UserProfileModel.dart';
import '../model/TrackedExerciseModel.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo;
  final String userId;

  ProfileViewModel(this._repo, {required this.userId});

  UserProfileModel? user;
  int workoutCount = 0;
  int totalSets = 0;
  int friendsCount = 0;
  List<TrackedExerciseModel> trackedExercises = [];
  bool isLoading = true;
  String? error;

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final userResult = await _repo.getUser(userId);
      final stats = await _repo.getStats(userId);
      final tracked = await _repo.getTrackedExercises(userId);
      final friends = await SocialRepository().getFriends(userId);
      user = userResult;
      workoutCount = stats.workoutCount;
      totalSets = stats.totalSets;
      friendsCount = friends.length;
      trackedExercises = tracked;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTracked(List<Map<String, dynamic>> exercises) async {
    for (final ex in exercises) {
      if (trackedExercises.any((t) => t.exerciseId == ex['id'])) continue;
      await _repo.addTracked(userId, ex['id'] as String);
    }
    await _reloadTracked();
  }

  Future<void> removeTracked(String id) async {
    trackedExercises.removeWhere((t) => t.id == id);
    notifyListeners();
    await _repo.removeTracked(id);
  }

  Future<void> setGoal(String id, double goalKg) async {
    final idx = trackedExercises.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    trackedExercises[idx] = trackedExercises[idx].copyWith(goalWeightKg: goalKg);
    notifyListeners();
    await _repo.updateGoalWeight(id, goalKg);
  }

  Future<void> updateBodyWeight(double weightKg) async {
    await _repo.updateBodyWeight(userId, weightKg);
    user = await _repo.getUser(userId);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    required String fullname,
    required String email,
    required double weightKg,
    String? gender,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.updateProfile(
        userId: userId,
        username: username,
        fullname: fullname,
        email: email,
        weightKg: weightKg,
        gender: gender,
      );
      user = await _repo.getUser(userId);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadAvatar(File file) async {
    await _repo.uploadAvatar(file, userId);
    user = await _repo.getUser(userId);
    notifyListeners();
  }

  Future<void> _reloadTracked() async {
    trackedExercises = await _repo.getTrackedExercises(userId);
    notifyListeners();
  }
}
