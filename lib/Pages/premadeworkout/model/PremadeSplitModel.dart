class PremadeExerciseModel {
  final String id;
  final String name;
  final int orderIndex;

  const PremadeExerciseModel({
    required this.id,
    required this.name,
    required this.orderIndex,
  });
}

class PremadeDayModel {
  final String id;
  final String name;
  final int dayOrder;
  final List<PremadeExerciseModel> exercises;

  const PremadeDayModel({
    required this.id,
    required this.name,
    required this.dayOrder,
    required this.exercises,
  });
}

class PremadeSplitModel {
  final String id;
  final String name;
  final String description;
  final List<PremadeDayModel> days;

  const PremadeSplitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
  });

  factory PremadeSplitModel.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['premade_split_days'] as List?) ?? [];
    final days = rawDays.map((d) {
      final rawExercises = (d['premade_split_exercises'] as List?) ?? [];
      final exercises = rawExercises.map((e) {
        final ex = e['exercises'] as Map<String, dynamic>? ?? {};
        return PremadeExerciseModel(
          id: ex['id'] as String? ?? '',
          name: ex['name'] as String? ?? '',
          orderIndex: e['order_index'] as int? ?? 0,
        );
      }).toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return PremadeDayModel(
        id: d['id'] as String,
        name: d['name'] as String? ?? '',
        dayOrder: d['day_order'] as int? ?? 0,
        exercises: exercises,
      );
    }).toList()
      ..sort((a, b) => a.dayOrder.compareTo(b.dayOrder));

    return PremadeSplitModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      days: days,
    );
  }
}
