class TrackedExerciseModel {
  final String id;
  final String exerciseId;
  final String name;
  final String muscle;
  final double? maxWeightKg;
  final double? goalWeightKg;

  const TrackedExerciseModel({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.muscle,
    this.maxWeightKg,
    this.goalWeightKg,
  });

  factory TrackedExerciseModel.fromJson(Map<String, dynamic> json) {
    return TrackedExerciseModel(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String? ?? '',
      muscle: json['muscle'] as String? ?? '',
      maxWeightKg: (json['maxWeightKg'] as num?)?.toDouble(),
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'name': name,
      'muscle': muscle,
      'maxWeightKg': maxWeightKg,
      'goalWeightKg': goalWeightKg,
    };
  }

  double? get progress {
    if (maxWeightKg == null || goalWeightKg == null || goalWeightKg! <= 0) {
      return null;
    }
    return (maxWeightKg! / goalWeightKg!).clamp(0.0, 1.0);
  }

  TrackedExerciseModel copyWith({double? goalWeightKg}) {
    return TrackedExerciseModel(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscle: muscle,
      maxWeightKg: maxWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
    );
  }
}
