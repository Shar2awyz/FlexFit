import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flex_fit/services/cache_service.dart';
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

  Future<void> _saveToCache() async {
    try {
      await CacheService.put('profile_data_$userId', {
        'user': user?.toJson(),
        'workoutCount': workoutCount,
        'totalSets': totalSets,
        'friendsCount': friendsCount,
        'trackedExercises': trackedExercises.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      print("Error saving profile to cache: $e");
    }
  }

  Future<void> loadAll() async {
    final cached = CacheService.get('profile_data_$userId');
    if (cached != null) {
      try {
        final cachedUser = cached['user'] as Map<String, dynamic>?;
        final cachedWorkoutCount = cached['workoutCount'] as int?;
        final cachedTotalSets = cached['totalSets'] as int?;
        final cachedFriendsCount = cached['friendsCount'] as int?;
        final cachedTracked = cached['trackedExercises'] as List?;

        if (cachedUser != null) {
          user = UserProfileModel.fromJson(cachedUser);
        }
        if (cachedWorkoutCount != null) {
          workoutCount = cachedWorkoutCount;
        }
        if (cachedTotalSets != null) {
          totalSets = cachedTotalSets;
        }
        if (cachedFriendsCount != null) {
          friendsCount = cachedFriendsCount;
        }
        if (cachedTracked != null) {
          trackedExercises = cachedTracked
              .map((e) => TrackedExerciseModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        isLoading = false;
        error = null;
        notifyListeners();
      } catch (e) {
        print("Error restoring profile cache: $e");
      }
    } else {
      isLoading = true;
      error = null;
      notifyListeners();
    }

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
      error = null;
      await _saveToCache();
    } catch (e) {
      print("Error loading profile from network: $e");
      if (user == null) {
        error = e.toString();
      }
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
    await _saveToCache();
  }

  Future<void> setGoal(String id, double goalKg) async {
    final idx = trackedExercises.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    trackedExercises[idx] = trackedExercises[idx].copyWith(goalWeightKg: goalKg);
    notifyListeners();
    await _repo.updateGoalWeight(id, goalKg);
    await _saveToCache();
  }

  Future<void> updateBodyWeight(double weightKg) async {
    await _repo.updateBodyWeight(userId, weightKg);
    user = await _repo.getUser(userId);
    notifyListeners();
    await _saveToCache();
  }

  Future<void> updateProfile({
    required String username,
    required String fullname,
    required String email,
    required double weightKg,
    String? gender,
    int? restDaysPerWeek,
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
        restDaysPerWeek: restDaysPerWeek,
      );
      user = await _repo.getUser(userId);
      await _saveToCache();
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
    await _saveToCache();
  }

  Future<void> _reloadTracked() async {
    trackedExercises = await _repo.getTrackedExercises(userId);
    notifyListeners();
    await _saveToCache();
  }
}
