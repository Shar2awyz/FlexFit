class SetModel {
  final int reps;
  final double weight;
  final int number;

  SetModel({
    required this.reps,
    required this.weight,
    required this.number,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      reps: json['reps'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      number: json['set_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'set_number': number,
    };
  }
}