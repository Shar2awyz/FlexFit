class SplitSummaryModel {
  final String id;
  final String name;
  final int dayCount;

  const SplitSummaryModel({
    required this.id,
    required this.name,
    required this.dayCount,
  });

  factory SplitSummaryModel.fromJson(Map<String, dynamic> json) {
    return SplitSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      dayCount: (json['split_days'] as List?)?.length ?? 0,
    );
  }

  SplitSummaryModel copyWith({String? name}) {
    return SplitSummaryModel(
      id: id,
      name: name ?? this.name,
      dayCount: dayCount,
    );
  }
}

class PremadeSplitSummary {
  final String id;
  final String name;
  final String? photoUrl;

  const PremadeSplitSummary({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory PremadeSplitSummary.fromJson(Map<String, dynamic> json) {
    return PremadeSplitSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
    );
  }
}
