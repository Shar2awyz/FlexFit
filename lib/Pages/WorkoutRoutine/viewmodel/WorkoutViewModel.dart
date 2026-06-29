import 'package:flex_fit/services/cache_service.dart';
import '../WorkoutRepository.dart';
import '../model/SetModel.dart';
import '../model/SplitDay.dart';
import '../model/ExerciseModel.dart';

class WorkoutViewModel {
  final repo = WorkoutRepository();


  Future<List<ExerciseModel>> loadExercisesWithSets(String dayId) async {
    final cached = CacheService.get('routine_exercises_$dayId');
    List<ExerciseModel>? cachedList;
    if (cached != null) {
      try {
        cachedList = (cached as List)
            .map((e) => ExerciseModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        print("Error restoring exercises list cache: $e");
      }
    }

    try {
      final userId = repo.supabase.auth.currentUser!.id;

      final data = await repo.supabase
          .from('split_exercises')
          .select('''
            exercise_id,
            order_index,
            exercises (
              id,
              name,
              muscle_group
            )
          ''')
          .eq('split_day_id', dayId)
          .order('order_index', ascending: true);

      final sortedData = List.from(data)..sort((a, b) {
        final aOrd = a['order_index'] as int? ?? 0;
        final bOrd = b['order_index'] as int? ?? 0;
        return aOrd.compareTo(bOrd);
      });

      List<ExerciseModel> result = [];

      for (var e in sortedData) {
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

      await CacheService.put(
        'routine_exercises_$dayId',
        result.map((e) => e.toJson()).toList(),
      );

      return result;
    } catch (e) {
      print("Error loading exercises from network: $e");
      if (cachedList != null) {
        return cachedList;
      }
      rethrow;
    }
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