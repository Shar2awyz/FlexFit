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

  double get maxWeight {
    if (sets.isEmpty) return 0.0;
    return sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  }
}

class WorkoutSessionDetail {
  final String id;
  final String name;
  final DateTime date;
  final int durationSeconds;
  final List<ExerciseDetail> exercises;
  final Map<String, dynamic>? progressSummary;
  final String? notes;

  WorkoutSessionDetail({
    required this.id,
    required this.name,
    required this.date,
    required this.durationSeconds,
    required this.exercises,
    this.progressSummary,
    this.notes,
  });

  factory WorkoutSessionDetail.fromMap(Map<String, dynamic> map) {
    final rawExercises = List<Map<String, dynamic>>.from(map['workout_exercises'] as List? ?? []);
    rawExercises.sort((a, b) {
      final aOrd = a['order_index'] as int? ?? 0;
      final bOrd = b['order_index'] as int? ?? 0;
      return aOrd.compareTo(bOrd);
    });
    return WorkoutSessionDetail(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Workout',
      date: DateTime.parse(map['date'] as String),
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      exercises: rawExercises
          .map((e) => ExerciseDetail.fromMap(e))
          .toList(),
      progressSummary: map['progress_summary'] as Map<String, dynamic>?,
      notes: map['notes'] as String?,
    );
  }

  double get totalVolume {
    double volume = 0.0;
    for (final ex in exercises) {
      for (final set in ex.sets) {
        volume += set.reps * set.weight;
      }
    }
    return volume;
  }

  int get totalSetsCount {
    return exercises.fold(0, (sum, ex) => sum + ex.sets.length);
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
