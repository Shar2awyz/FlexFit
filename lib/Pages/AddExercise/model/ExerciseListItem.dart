class ExerciseListItem {
  final String id;
  final String name;
  final String muscleGroup;
  final String? photoUrl;

  const ExerciseListItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.photoUrl,
  });

  factory ExerciseListItem.fromJson(Map<String, dynamic> json) {
    return ExerciseListItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscle_group'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
    );
  }
}
