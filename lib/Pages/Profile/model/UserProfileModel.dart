class UserProfileModel {
  final String id;
  final String username;
  final String? imageUrl;
  final double weightKg;
  final String? createdAt;
  final String fullname;
  final String email;
  final String? gender;
  final int restDaysPerWeek;

  const UserProfileModel({
    required this.id,
    required this.username,
    this.imageUrl,
    required this.weightKg,
    this.createdAt,
    required this.fullname,
    required this.email,
    this.gender,
    this.restDaysPerWeek = 4,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final weightRaw = json['weight(kg)'];
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'User',
      imageUrl: json['image_url'] as String?,
      weightKg: weightRaw is num ? weightRaw.toDouble() : 0.0,
      createdAt: json['created_at'] as String?,
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gender: json['Gender'] as String?,
      restDaysPerWeek: json['rest_days_per_week'] as int? ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'image_url': imageUrl,
      'weight(kg)': weightKg,
      'created_at': createdAt,
      'fullname': fullname,
      'email': email,
      'Gender': gender,
      'rest_days_per_week': restDaysPerWeek,
    };
  }

  String get memberSince {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
