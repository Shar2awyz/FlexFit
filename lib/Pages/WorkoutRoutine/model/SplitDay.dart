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

  factory SplitDay.fromJson(Map<String, dynamic> json) {
    return SplitDay(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: json['day_order'] as int? ?? 0,
      exercises: (json['exercises'] as List?)
          ?.map((e) => ExerciseModel.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'day_order': order,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}