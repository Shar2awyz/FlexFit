import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_fit/services/cache_service.dart';
import 'WorkoutBeginState.dart';

import '../../Repository.dart';
import '../../model/ExerciseWithSets.dart';
import '../../model/SetModel.dart';

class WorkoutBeginCubit extends Cubit<WorkoutBeginState> {
  final WorkoutBeginRepository repo;

  WorkoutBeginCubit(this.repo) : super(WorkoutBeginInitial());

  String? workoutId;
  String? _splitDayId;
  String? workoutName;
  DateTime? startTime;

  List<ExerciseWithSets> exercises = [];

  int totalSets = 0;
  double totalVolume = 0;

  final Set<String> _exercisesAddedThisWorkout = {};
  bool _orderChanged = false;

  String? get splitDayId => _splitDayId;
  bool get isWorkoutInProgress => state is WorkoutBeginLoaded || state is WorkoutBeginLoading;

  bool get hasStructuralChanges =>
      _exercisesAddedThisWorkout.isNotEmpty || _orderChanged;

  Future<void> _saveToCache() async {
    final userId = repo.supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (workoutId == null) {
      await CacheService.delete('active_workout_state_$userId');
      return;
    }

    final data = {
      'workoutId': workoutId,
      'splitDayId': _splitDayId,
      'workoutName': workoutName,
      'startTime': startTime?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'totalSets': totalSets,
      'totalVolume': totalVolume,
      'exercisesAddedThisWorkout': _exercisesAddedThisWorkout.toList(),
      'orderChanged': _orderChanged,
    };
    await CacheService.put('active_workout_state_$userId', data);
  }

  Future<void> _clearCache() async {
    final userId = repo.supabase.auth.currentUser?.id;
    if (userId == null) return;
    await CacheService.delete('active_workout_state_$userId');
  }

  Future<void> checkAndResumeActiveWorkout(String userId) async {
    final cached = CacheService.get('active_workout_state_$userId');
    if (cached == null) return;

    try {
      workoutId = cached['workoutId'] as String?;
      _splitDayId = cached['splitDayId'] as String?;
      workoutName = cached['workoutName'] as String?;
      if (cached['startTime'] != null) {
        startTime = DateTime.parse(cached['startTime'] as String);
      }
      totalSets = cached['totalSets'] as int? ?? 0;
      totalVolume = (cached['totalVolume'] as num? ?? 0).toDouble();

      final exList = cached['exercises'] as List?;
      if (exList != null) {
        exercises = exList
            .map((e) => ExerciseWithSets.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final addedList = cached['exercisesAddedThisWorkout'] as List?;
      if (addedList != null) {
        _exercisesAddedThisWorkout.clear();
        _exercisesAddedThisWorkout.addAll(addedList.cast<String>());
      }
      _orderChanged = cached['orderChanged'] as bool? ?? false;

      _emitLoaded();
    } catch (e) {
      print("Error resuming active workout: $e");
      await _clearCache();
    }
  }

  void _emitLoaded() => emit(WorkoutBeginLoaded(
        List.from(exercises),
        totalSets: totalSets,
        totalVolume: totalVolume,
      ));

  Future<void> startWorkout({
    required String userId,
    required String dayId,
    required String name,
  }) async {
    _splitDayId = dayId;
    workoutName = name;
    emit(WorkoutBeginLoading());

    try {
      startTime = DateTime.now();
      workoutId = await repo.createWorkout(userId: userId, name: name);

      final data = await repo.getDayExercises(dayId);
      final sortedData = List.from(data)..sort((a, b) {
        final aOrd = a['order_index'] as int? ?? 0;
        final bOrd = b['order_index'] as int? ?? 0;
        return aOrd.compareTo(bOrd);
      });
      int order = 0;
      final temp = <ExerciseWithSets>[];

      for (final e in sortedData) {
        final ex = e['exercises'];
        final weId = await repo.createWorkoutExercise(
          workoutId: workoutId!,
          exerciseId: ex['id'],
          order: order++,
        );
        final prev = await repo.getPreviousSets(
            exerciseId: ex['id'], excludeWorkoutId: workoutId);
        final setsCount = (e['sets_count'] as int?) ?? 3;
        temp.add(ExerciseWithSets(
          exerciseId: ex['id'],
          name: ex['name'],
          muscleGroup: ex['muscle_group'],
          photo_url: ex['photo_url'],
          workoutExerciseId: weId,
          plannedSets: setsCount,
          previousSets: prev.map<SetModel>((s) => SetModel.fromJson(s)).toList(),
        ));
      }

      exercises = temp;
      _emitLoaded();
      await _saveToCache();
    } catch (e) {
      emit(WorkoutBeginError(e.toString()));
    }
  }

  Future<void> addSet({
    required int exerciseIndex,
    required int reps,
    required double weight,
  }) async {
    final ex = exercises[exerciseIndex];
    final newSet = SetModel(
      reps: reps,
      weight: weight,
      number: ex.sets.length + 1,
    );
    totalSets += 1;
    totalVolume += (weight * reps);
    _emitLoaded();
    await _saveToCache();

    // Insert and store the returned UUID so the set can be deleted later.
    final dbId = await repo.insertSet(newSet.toInsert(ex.workoutExerciseId!));
    exercises[exerciseIndex].sets.add(SetModel(
      dbId: dbId,
      reps: reps,
      weight: weight,
      number: newSet.number,
    ));
    await _saveToCache();
  }

  /// Called when the user swipes away a set row.
  /// [setsListIndex] is the position in exercises[exIdx].sets (only completed sets).
  Future<void> removeSet(String exerciseId, int setsListIndex) async {
    final exIdx = exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (exIdx == -1) return;
    if (setsListIndex >= exercises[exIdx].sets.length) return;

    final removed = exercises[exIdx].sets.removeAt(setsListIndex);
    totalSets = (totalSets - 1).clamp(0, double.maxFinite).toInt();
    totalVolume = (totalVolume - removed.weight * removed.reps)
        .clamp(0, double.maxFinite);
    _emitLoaded();
    await _saveToCache();

    if (removed.dbId != null) {
      await repo.removeSet(removed.dbId!);
    }
  }

  /// Deletes the entire workout and all its data from the backend.
  Future<void> deleteWorkout() async {
    if (workoutId == null) return;
    await repo.deleteWorkout(workoutId!);
    await _clearCache();
    emit(WorkoutFinished());
  }

  /// Add exercises mid-workout (split update is deferred until Finish).
  Future<void> addExercises(List<Map<String, dynamic>> exercisesData) async {
    if (workoutId == null) return;

    int order = exercises.length;

    for (final exData in exercisesData) {
      final weId = await repo.createWorkoutExercise(
        workoutId: workoutId!,
        exerciseId: exData['id'],
        order: order,
      );
      final prev = await repo.getPreviousSets(
          exerciseId: exData['id'], excludeWorkoutId: workoutId);
      exercises.add(ExerciseWithSets(
        exerciseId: exData['id'],
        name: exData['name'],
        muscleGroup: exData['muscle_group'],
        photo_url: exData['photo_url'] ?? '',
        workoutExerciseId: weId,
        previousSets: prev.map<SetModel>((s) => SetModel.fromJson(s)).toList(),
      ));
      _exercisesAddedThisWorkout.add(exData['id'] as String);
      order++;
    }

    _emitLoaded();
    await _saveToCache();
  }

  /// Remove an exercise from the current workout.
  Future<void> removeExercise(String exerciseId) async {
    final idx = exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (idx == -1) return;

    final ex = exercises.removeAt(idx);
    _emitLoaded();
    await _saveToCache();

    if (ex.workoutExerciseId != null) {
      await repo.removeWorkoutExercise(ex.workoutExerciseId!);
    }
  }

  /// Swap an exercise with a different one (keeps the same workout_exercise row).
  Future<void> replaceExercise(
      String exerciseId, Map<String, dynamic> newExData) async {
    final idx = exercises.indexWhere((e) => e.exerciseId == exerciseId);
    if (idx == -1) return;

    final oldEx = exercises[idx];
    final prev = await repo.getPreviousSets(
        exerciseId: newExData['id'], excludeWorkoutId: workoutId);

    exercises[idx] = ExerciseWithSets(
      exerciseId: newExData['id'],
      name: newExData['name'],
      muscleGroup: newExData['muscle_group'],
      photo_url: newExData['photo_url'] ?? '',
      workoutExerciseId: oldEx.workoutExerciseId,
      previousSets: prev.map<SetModel>((s) => SetModel.fromJson(s)).toList(),
    );

    _emitLoaded();
    await _saveToCache();

    if (oldEx.workoutExerciseId != null) {
      await repo.replaceWorkoutExercise(
        workoutExerciseId: oldEx.workoutExerciseId!,
        newExerciseId: newExData['id'],
      );
    }
  }

  /// Drag-to-reorder: moves item and updates workout session order.
  /// Split order is saved only if user chooses "Save permanently" on Finish.
  Future<void> reorderExercises(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    _orderChanged = true;
    _emitLoaded();
    await _saveToCache();

    for (int i = 0; i < exercises.length; i++) {
      final weId = exercises[i].workoutExerciseId;
      if (weId != null) {
        await repo.updateWorkoutExerciseOrder(weId, i);
      }
    }
  }

  /// Saves structural changes (new exercises, order, set counts) to the split.
  /// Only called when the user explicitly chooses "Save permanently".
  Future<void> saveChangesToSplit({
    required Map<String, int> setCountsPerExercise,
  }) async {
    if (_splitDayId == null) return;

    // Insert newly added exercises into the split.
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      if (_exercisesAddedThisWorkout.contains(ex.exerciseId)) {
        await repo.addExerciseToSplitDay(
          splitDayId: _splitDayId!,
          exerciseId: ex.exerciseId,
          orderIndex: i + 1,
        );
      }
    }

    // Persist new exercise order to the split.
    if (_orderChanged) {
      for (int i = 0; i < exercises.length; i++) {
        await repo.updateSplitExerciseOrder(
          splitDayId: _splitDayId!,
          exerciseId: exercises[i].exerciseId,
          orderIndex: i + 1,
        );
      }
    }

    // Persist set counts that differ from the planned value.
    for (final ex in exercises) {
      final newCount = setCountsPerExercise[ex.exerciseId];
      if (newCount != null && newCount != ex.plannedSets) {
        await repo.updateSplitSetsCount(
          splitDayId: _splitDayId!,
          exerciseId: ex.exerciseId,
          setsCount: newCount,
        );
      }
    }
  }

  Future<void> finishWorkout() async {
    if (workoutId == null || startTime == null) return;
    final duration = DateTime.now().difference(startTime!).inSeconds;
    await repo.finishWorkout(workoutId: workoutId!, durationSeconds: duration);
    await _clearCache();
    emit(WorkoutFinished());
  }
}
