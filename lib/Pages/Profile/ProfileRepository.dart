import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_fit/services/services.dart';
import 'model/UserProfileModel.dart';
import 'model/TrackedExerciseModel.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;
  final _supa = supa();

  Future<UserProfileModel> getUser(String userId) async {
    final data = await _supabase
        .from('Users')
        .select()
        .eq('id', userId)
        .single();
    return UserProfileModel.fromJson(data);
  }

  Future<({int workoutCount, int totalSets})> getStats(String userId) async {
    final workouts = await _supabase
        .from('workouts')
        .select('id')
        .eq('user_id', userId);
    final workoutCount = (workouts as List).length;

    final we = await _supabase
        .from('workout_exercises')
        .select('id, workouts!inner(user_id)')
        .eq('workouts.user_id', userId);

    int totalSets = 0;
    if ((we as List).isNotEmpty) {
      final ids = we.map((e) => e['id'] as String).toList();
      final sets = await _supabase
          .from('sets')
          .select('id')
          .inFilter('workout_exercise_id', ids);
      totalSets = (sets as List).length;
    }

    return (workoutCount: workoutCount, totalSets: totalSets);
  }

  Future<List<TrackedExerciseModel>> getTrackedExercises(
      String userId) async {
    final rows = await _supabase
        .from('tracked_exercises')
        .select(
            'id, exercise_id, goal_weight, exercises(name, muscle_group)')
        .eq('user_id', userId);

    final list = <TrackedExerciseModel>[];
    for (final row in rows as List) {
      final ex = row['exercises'] as Map<String, dynamic>;
      final maxW = await _getMaxWeight(row['exercise_id'] as String, userId);
      list.add(TrackedExerciseModel(
        id: row['id'] as String,
        exerciseId: row['exercise_id'] as String,
        name: ex['name'] as String? ?? '',
        muscle: ex['muscle_group'] as String? ?? '',
        maxWeightKg: maxW,
        goalWeightKg: (row['goal_weight'] as num?)?.toDouble(),
      ));
    }
    return list;
  }

  Future<double?> _getMaxWeight(String exerciseId, String userId) async {
    try {
      final we = await _supabase
          .from('workout_exercises')
          .select('id, workouts!inner(user_id)')
          .eq('exercise_id', exerciseId)
          .eq('workouts.user_id', userId);

      if ((we as List).isEmpty) return null;
      final ids = we.map((e) => e['id'] as String).toList();

      final sets = await _supabase
          .from('sets')
          .select('weight')
          .inFilter('workout_exercise_id', ids);

      if ((sets as List).isEmpty) return null;
      return sets
          .map((s) => (s['weight'] as num).toDouble())
          .reduce((a, b) => a > b ? a : b);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTracked(String userId, String exerciseId) async {
    await _supabase.from('tracked_exercises').upsert({
      'user_id': userId,
      'exercise_id': exerciseId,
    });
  }

  Future<void> removeTracked(String id) async {
    await _supabase.from('tracked_exercises').delete().eq('id', id);
  }

  Future<void> updateGoalWeight(String id, double goalKg) async {
    await _supabase
        .from('tracked_exercises')
        .update({'goal_weight': goalKg.round()})
        .eq('id', id);
  }

  Future<void> updateBodyWeight(String userId, double weightKg) async {
    await _supabase
        .from('Users')
        .update({'weight(kg)': weightKg.round()})
        .eq('id', userId);
  }

  Future<void> updateProfile({
    required String userId,
    required String username,
    required String fullname,
    required String email,
    required double weightKg,
    String? gender,
    int? restDaysPerWeek,
  }) async {
    // 1. Update Users table
    await _supabase
        .from('Users')
        .update({
          'username': username,
          'fullname': fullname,
          'email': email,
          'weight(kg)': weightKg,
          'Gender': gender,
          'rest_days_per_week': restDaysPerWeek,
        })
        .eq('id', userId);

    // 2. Try to update Auth user email if changed
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null && currentUser.email != email) {
        await _supabase.auth.updateUser(UserAttributes(email: email));
      }
    } catch (e) {
      print("Warning: Failed to update Supabase Auth email: $e");
    }
  }

  Future<void> uploadAvatar(File file, String userId) async {
    await _supa.uploadImage(file, userId);
  }
}
