import '../../model/ExerciseWithSets.dart';

abstract class WorkoutBeginState {}

class WorkoutBeginInitial extends WorkoutBeginState {}

class WorkoutBeginLoading extends WorkoutBeginState {}

class WorkoutBeginLoaded extends WorkoutBeginState {
  final List<ExerciseWithSets> exercises;
  final int totalSets;
  final double totalVolume;

  WorkoutBeginLoaded(
      this.exercises, {
        required this.totalSets,
        required this.totalVolume,
      });
}

class WorkoutBeginError extends WorkoutBeginState {
  final String message;
  WorkoutBeginError(this.message);
}

class WorkoutFinished extends WorkoutBeginState {}