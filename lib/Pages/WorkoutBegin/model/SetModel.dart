class SetModel {
  final String? dbId; // UUID returned after insert — used to delete the row
  final int reps;
  final double weight;
  final int number;

  SetModel({
    this.dbId,
    required this.reps,
    required this.weight,
    required this.number,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      dbId: json['dbId'] as String?,
      reps: json['reps'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      number: json['set_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dbId': dbId,
      'reps': reps,
      'weight': weight,
      'set_number': number,
    };
  }

  Map<String, dynamic> toInsert(String workoutExerciseId) {
    return {
      'workout_exercise_id': workoutExerciseId,
      'reps': reps,
      'weight': weight,
      'set_number': number,
    };
  }
}
