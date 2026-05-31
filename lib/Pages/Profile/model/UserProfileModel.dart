class UserProfileModel {
  final String id;
  final String username;
  final String? imageUrl;
  final double weightKg;
  final String? createdAt;
  final String fullname;
  final String email;
  final String? gender;

  const UserProfileModel({
    required this.id,
    required this.username,
    this.imageUrl,
    required this.weightKg,
    this.createdAt,
    required this.fullname,
    required this.email,
    this.gender,
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
    );
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
