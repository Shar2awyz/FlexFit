import '../WorkoutRepository.dart';
import '../model/SetModel.dart';
import '../model/SplitDay.dart';
import '../model/ExerciseModel.dart';

class WorkoutViewModel {
  final repo = WorkoutRepository();


  Future<List<ExerciseModel>> loadExercisesWithSets(String dayId) async {
    final userId = repo.supabase.auth.currentUser!.id;

    final data = await repo.supabase
        .from('split_exercises')
        .select('''
          exercise_id,
          exercises (
            id,
            name,
            muscle_group
          )
        ''')
        .eq('split_day_id', dayId)
        .order('order_index');

    List<ExerciseModel> result = [];

    for (var e in data) {
      final exercise = e['exercises'];

      List<SetModel>? sets;

      // Get the most recent completed workout_exercise for this exercise
      // (ordered by workout date desc, filtered by user, only rows with sets).
      final weList = await repo.supabase
          .from('workout_exercises')
          .select('id, workouts!inner(date, user_id)')
          .eq('exercise_id', exercise['id'])
          .eq('workouts.user_id', userId)
          .order('date', referencedTable: 'workouts', ascending: false)
          .limit(5); // fetch a few so we can find one that has sets

      for (final we in weList) {
        final setsData = await repo.supabase
            .from('sets')
            .select()
            .eq('workout_exercise_id', we['id'] as String)
            .order('set_number');

        if (setsData.isNotEmpty) {
          sets = setsData
              .map<SetModel>((s) => SetModel.fromJson(s))
              .toList();
          break; // found the most recent session that has sets
        }
      }

      result.add(ExerciseModel(
        id: exercise['id'],
        name: exercise['name'],
        muscleGroup: exercise['muscle_group'],
        sets: sets,
      ));
    }

    return result;
  }

  /// 🔹 يجيب الأيام (days) بس
  Future<List<SplitDay>> loadRoutine(String splitId) async {
    final data = await repo.supabase
        .from('split_days')
        .select('''
          id,
          name,
          day_order,
          split_exercises (
            exercise_id
          )
        ''')
        .eq('split_id', splitId)
        .order('day_order');

    return data.map<SplitDay>((e) {
      final exercises = e['split_exercises'] as List;

      return SplitDay(
        id: e['id'],
        name: e['name'],
        order: e['day_order'],
        exercises: List.generate(
          exercises.length,
              (_) => ExerciseModel(
            id: '',
            name: '',
            muscleGroup: '',
          ),
        ),
      );
    }).toList();
  }
}