class WorkoutHistoryModel {
  final String id;
  final String name;
  final DateTime date;
  final int durationSeconds;
  final int exerciseCount;
  final int totalSets;

  WorkoutHistoryModel({
    required this.id,
    required this.name,
    required this.date,
    required this.durationSeconds,
    required this.exerciseCount,
    required this.totalSets,
  });

  factory WorkoutHistoryModel.fromMap(Map<String, dynamic> map) {
    final exercises = (map['workout_exercises'] as List?) ?? [];
    int sets = 0;
    for (final ex in exercises) {
      sets += ((ex['sets'] as List?) ?? []).length;
    }
    return WorkoutHistoryModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Workout',
      date: DateTime.parse(map['date'] as String),
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      exerciseCount: exercises.length,
      totalSets: sets,
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
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
