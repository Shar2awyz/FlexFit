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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscle_group'] as String? ?? '',
      sets: (json['sets'] as List?)
          ?.map((e) => SetModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'sets': sets?.map((e) => e.toJson()).toList(),
    };
  }
}