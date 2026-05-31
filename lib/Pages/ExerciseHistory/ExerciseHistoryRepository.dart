import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/ExerciseSetRecord.dart';

class ExerciseHistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<ExerciseSetRecord>> getSets(
    String exerciseId,
    String userId,
  ) async {
    final we = await _supabase
        .from('workout_exercises')
        .select('id, workouts!inner(name, date, user_id)')
        .eq('exercise_id', exerciseId)
        .eq('workouts.user_id', userId);

    if ((we as List).isEmpty) return [];

    final weIds = we.map((e) => e['id'] as String).toList();
    final weMap = {
      for (final w in we)
        w['id'] as String: w['workouts'] as Map<String, dynamic>
    };

    final sets = await _supabase
        .from('sets')
        .select('weight, reps, set_number, workout_exercise_id')
        .inFilter('workout_exercise_id', weIds)
        .order('weight', ascending: false);

    return (sets as List).map((s) {
      final workout = weMap[s['workout_exercise_id'] as String];
      return ExerciseSetRecord(
        weight: (s['weight'] as num).toDouble(),
        reps: s['reps'] as int,
        setNumber: s['set_number'] as int,
        workoutName: workout?['name'] as String? ?? 'Workout',
        workoutDate: workout?['date'] as String?,
      );
    }).toList();
  }
}
