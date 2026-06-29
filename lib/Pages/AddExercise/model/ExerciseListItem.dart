class ExerciseListItem {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String? photoUrl;

  const ExerciseListItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.photoUrl,
  });

  factory ExerciseListItem.fromJson(Map<String, dynamic> json) {
    return ExerciseListItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscle_group'] as String? ?? '',
      equipment: json['equipment'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'photo_url': photoUrl,
    };
  }
}
