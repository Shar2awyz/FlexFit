import 'SetModel.dart';

import 'SetModel.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final List<SetModel>? sets;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.sets,
  });



  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscle_group'],

    );
  }
}