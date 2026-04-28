import 'SetModel.dart';

class ExerciseWithSets {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final String photo_url;

  final String? workoutExerciseId;

  /// how many set rows to show when the workout starts
  final int plannedSets;

  final List<SetModel> sets;
  final List<SetModel> previousSets;

  ExerciseWithSets({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    this.workoutExerciseId,
    required this.photo_url,
    this.plannedSets = 3,
    List<SetModel>? sets,
    List<SetModel>? previousSets,
  })  : sets = sets ?? [],
        previousSets = previousSets ?? [];

  ExerciseWithSets copyWith({
    String? workoutExerciseId,
    int? plannedSets,
    List<SetModel>? sets,
    List<SetModel>? previousSets,
  }) {
    return ExerciseWithSets(
      exerciseId: exerciseId,
      name: name,
      muscleGroup: muscleGroup,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      photo_url: photo_url,
      plannedSets: plannedSets ?? this.plannedSets,
      sets: sets ?? this.sets,
      previousSets: previousSets ?? this.previousSets,
    );
  }
}