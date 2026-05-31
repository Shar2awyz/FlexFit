class ExerciseDetailModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String? videoUrl;

  const ExerciseDetailModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.videoUrl,
  });

  factory ExerciseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExerciseDetailModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      muscleGroup: json['muscle_group'] as String? ?? '',
      equipment: json['equipment'] as String? ?? 'N/A',
      videoUrl: json['video_url'] as String?,
    );
  }
}
