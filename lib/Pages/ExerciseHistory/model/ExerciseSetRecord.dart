class ExerciseSetRecord {
  final double weight;
  final int reps;
  final int setNumber;
  final String workoutName;
  final String? workoutDate;

  const ExerciseSetRecord({
    required this.weight,
    required this.reps,
    required this.setNumber,
    required this.workoutName,
    this.workoutDate,
  });

  String formattedWeight(bool isKg) => isKg
      ? '${weight.toStringAsFixed(1)} kg'
      : '${(weight * 2.205).toStringAsFixed(1)} lbs';

  String get formattedDate {
    if (workoutDate == null) return '';
    try {
      final dt = DateTime.parse(workoutDate!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
