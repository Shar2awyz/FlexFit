class SetDetail {
  final int setNumber;
  final int reps;
  final double weight;

  SetDetail({required this.setNumber, required this.reps, required this.weight});

  factory SetDetail.fromMap(Map<String, dynamic> map) {
    return SetDetail(
      setNumber: (map['set_number'] as num?)?.toInt() ?? 0,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ExerciseDetail {
  final String name;
  final String muscleGroup;
  final List<SetDetail> sets;

  ExerciseDetail({required this.name, required this.muscleGroup, required this.sets});

  factory ExerciseDetail.fromMap(Map<String, dynamic> map) {
    final exercise = map['exercises'] as Map<String, dynamic>? ?? {};
    final rawSets = (map['sets'] as List?) ?? [];
    final sets = rawSets
        .map((s) => SetDetail.fromMap(s as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
    return ExerciseDetail(
      name: exercise['name'] as String? ?? 'Exercise',
      muscleGroup: exercise['muscle_group'] as String? ?? '',
      sets: sets,
    );
  }
}

class WorkoutSessionDetail {
  final String id;
  final String name;
  final DateTime date;
  final int durationSeconds;
  final List<ExerciseDetail> exercises;

  WorkoutSessionDetail({
    required this.id,
    required this.name,
    required this.date,
    required this.durationSeconds,
    required this.exercises,
  });

  factory WorkoutSessionDetail.fromMap(Map<String, dynamic> map) {
    final rawExercises = (map['workout_exercises'] as List?) ?? [];
    return WorkoutSessionDetail(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Workout',
      date: DateTime.parse(map['date'] as String),
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      exercises: rawExercises
          .map((e) => ExerciseDetail.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get formattedDuration {
    final mins = durationSeconds ~/ 60;
    if (mins == 0) return '< 1 min';
    if (mins < 60) return '$mins min';
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    return rem == 0 ? '${hrs}h' : '${hrs}h ${rem}m';
  }

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
