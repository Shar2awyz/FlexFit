import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutBeginRepository {
  final supabase = Supabase.instance.client;

  Future<String> createWorkout({
    required String userId,
    required String name,
  }) async {
    final res = await supabase
        .from('workouts')
        .insert({'user_id': userId, 'name': name})
        .select('id')
        .maybeSingle();
    return res?['id'];
  }

  Future<List<dynamic>> getDayExercises(String dayId) async {
    final data = await supabase
        .from('split_exercises')
        .select('''
          exercise_id,
          order_index,
          sets_count,
          exercises (
            id,
            name,
            muscle_group,
            photo_url
          )
        ''')
        .eq('split_day_id', dayId)
        .order('order_index', ascending: true);
    return data;
  }

  Future<void> updateSetsCount({
    required String splitExerciseId,
    required int setsCount,
  }) async {
    await supabase
        .from('split_exercises')
        .update({'sets_count': setsCount})
        .eq('id', splitExerciseId);
  }

  Future<String> createWorkoutExercise({
    required String workoutId,
    required String exerciseId,
    required int order,
  }) async {
    final res = await supabase
        .from('workout_exercises')
        .insert({
          'workout_id': workoutId,
          'exercise_id': exerciseId,
          'order_index': order,
        })
        .select('id')
        .maybeSingle();
    return res?['id'];
  }

  Future<List<dynamic>> getPreviousSets({
    required String exerciseId,
    String? excludeWorkoutId,
  }) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      // Fetch all workout_exercises for this exercise belonging to this user.
      // Same pattern as ExerciseHistoryRepository — filter related table via !inner.
      final we = await supabase
          .from('workout_exercises')
          .select('id, workout_id, workouts!inner(date, user_id)')
          .eq('exercise_id', exerciseId)
          .eq('workouts.user_id', userId);

      if ((we as List).isEmpty) return [];

      // Filter out the current (in-progress) workout in Dart to avoid
      // query-builder issues with chained .neq() on related-table filters.
      final filtered = we
          .where((w) => w['workout_id'] != excludeWorkoutId)
          .toList();

      if (filtered.isEmpty) return [];

      // Sort by workout date descending to find the most recent session.
      filtered.sort((a, b) {
        final da = (a['workouts'] as Map)['date'] as String?;
        final db = (b['workouts'] as Map)['date'] as String?;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

      final sets = await supabase
          .from('sets')
          .select('reps, weight, set_number')
          .eq('workout_exercise_id', filtered[0]['id'] as String)
          .order('set_number');

      return sets as List;
    } catch (e, st) {
      // ignore: avoid_print
      print('getPreviousSets error: $e\n$st');
      return [];
    }
  }

  Future<double?> getPreviousMaxWeight({
    required String exerciseId,
    required String userId,
    required String excludeWorkoutId,
  }) async {
    try {
      final we = await supabase
          .from('workout_exercises')
          .select('id, workout_id, workouts!inner(user_id)')
          .eq('exercise_id', exerciseId)
          .eq('workouts.user_id', userId);

      if ((we as List).isEmpty) return null;
      final ids = we
          .where((w) => w['workout_id'] != excludeWorkoutId)
          .map((e) => e['id'] as String)
          .toList();

      if (ids.isEmpty) return null;

      final sets = await supabase
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

  /// Returns the UUID of the newly inserted set row.
  Future<String?> insertSet(Map<String, dynamic> data) async {
    final res = await supabase
        .from('sets')
        .insert(data)
        .select('id')
        .maybeSingle();
    return res?['id'] as String?;
  }

  /// Deletes a single set by its UUID.
  Future<void> removeSet(String setId) async {
    await supabase.from('sets').delete().eq('id', setId);
  }

  /// Deletes the entire workout and all related data.
  Future<void> deleteWorkout(String workoutId) async {
    final weList = await supabase
        .from('workout_exercises')
        .select('id')
        .eq('workout_id', workoutId);

    for (final we in weList) {
      await supabase
          .from('sets')
          .delete()
          .eq('workout_exercise_id', we['id'] as String);
    }

    await supabase
        .from('workout_exercises')
        .delete()
        .eq('workout_id', workoutId);

    await supabase.from('workouts').delete().eq('id', workoutId);
  }

  Future<void> finishWorkout({
    required String workoutId,
    required int durationSeconds,
  }) async {
    await supabase
        .from('workouts')
        .update({
          'duration_seconds': durationSeconds,
          'is_completed': true,
        })
        .eq('id', workoutId);
  }

  /// Saves a new exercise to the split so it appears in future workouts.
  Future<void> addExerciseToSplitDay({
    required String splitDayId,
    required String exerciseId,
    required int orderIndex,
  }) async {
    await supabase.from('split_exercises').insert({
      'split_day_id': splitDayId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
    });
  }

  /// Deletes a workout_exercise and all its sets.
  Future<void> removeWorkoutExercise(String workoutExerciseId) async {
    await supabase
        .from('sets')
        .delete()
        .eq('workout_exercise_id', workoutExerciseId);
    await supabase
        .from('workout_exercises')
        .delete()
        .eq('id', workoutExerciseId);
  }

  /// Swaps the exercise on an existing workout_exercise row and wipes its sets.
  Future<void> replaceWorkoutExercise({
    required String workoutExerciseId,
    required String newExerciseId,
  }) async {
    await supabase
        .from('sets')
        .delete()
        .eq('workout_exercise_id', workoutExerciseId);
    await supabase
        .from('workout_exercises')
        .update({'exercise_id': newExerciseId})
        .eq('id', workoutExerciseId);
  }

  /// Updates the order_index of a single workout_exercise row.
  Future<void> updateWorkoutExerciseOrder(
      String workoutExerciseId, int orderIndex) async {
    await supabase
        .from('workout_exercises')
        .update({'order_index': orderIndex})
        .eq('id', workoutExerciseId);
  }

  /// Updates the order_index of an exercise inside a split day.
  Future<void> updateSplitExerciseOrder({
    required String splitDayId,
    required String exerciseId,
    required int orderIndex,
  }) async {
    await supabase
        .from('split_exercises')
        .update({'order_index': orderIndex})
        .eq('split_day_id', splitDayId)
        .eq('exercise_id', exerciseId);
  }

  /// Updates the planned sets count for an exercise inside a split day.
  Future<void> updateSplitSetsCount({
    required String splitDayId,
    required String exerciseId,
    required int setsCount,
  }) async {
    await supabase
        .from('split_exercises')
        .update({'sets_count': setsCount})
        .eq('split_day_id', splitDayId)
        .eq('exercise_id', exerciseId);
  }
}
