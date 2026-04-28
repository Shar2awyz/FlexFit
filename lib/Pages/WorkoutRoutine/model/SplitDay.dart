import 'ExerciseModel.dart';

class SplitDay {
  final String id;
  final String name;
  final int order;
  final List<ExerciseModel> exercises;

  SplitDay({
    required this.id,
    required this.name,
    required this.order,
    required this.exercises,
  });
}