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
          sets_count,
          exercises (
            id,
            name,
            muscle_group,
            photo_url
          )
        ''')
        .eq('split_day_id', dayId)
        .order('order_index');
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

  Future<List<dynamic>> getPreviousSets({required String exerciseId}) async {
    try {
      final we = await supabase
          .from('workout_exercises')
          .select('''
            id,
            workouts!inner (date)
          ''')
          .eq('exercise_id', exerciseId)
          .eq('workouts.user_id', supabase.auth.currentUser!.id)
          .order('date', referencedTable: 'workouts', ascending: false)
          .limit(1);

      if (we.isEmpty) return [];

      final sets = await supabase
          .from('sets')
          .select('reps, weight, set_number')
          .eq('workout_exercise_id', we[0]['id'])
          .order('set_number');

      return sets;
    } catch (e) {
      return [];
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
        .update({'duration_seconds': durationSeconds})
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
