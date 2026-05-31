class SocialUserModel {
  final String id;
  final String username;
  final String? imageUrl;

  const SocialUserModel({
    required this.id,
    required this.username,
    this.imageUrl,
  });

  factory SocialUserModel.fromJson(Map<String, dynamic> json) {
    return SocialUserModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'User',
      imageUrl: json['image_url'] as String?,
    );
  }
}
