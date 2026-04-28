import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  final supabase = Supabase.instance.client;

  /// 🔹 يجيب exercises من split
  Future<List<dynamic>> getExercises(String dayId) async {
    return await supabase
        .from('split_exercises')
        .select('''
          exercise_id,
          exercises (
            id,
            name,
            muscle_group
          )
        ''')
        .eq('split_day_id', dayId);
  }

  /// 🔹 يجيب workout_exercise
  Future<Map<String, dynamic>?> getWorkoutExercise(String exerciseId) async {
    final list = await supabase
        .from('workout_exercises')
        .select('id')
        .eq('exercise_id', exerciseId)
        .limit(1);
    return list.isEmpty ? null : list.first;
  }

  /// 🔹 يجيب sets
  Future<List<dynamic>> getSets(String workoutExerciseId) async {
    return await supabase
        .from('sets')
        .select()
        .eq('workout_exercise_id', workoutExerciseId);
  }
}