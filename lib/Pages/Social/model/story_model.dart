import 'social_user_model.dart';

class StoryModel {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime expiresAt;
  final DateTime createdAt;
  final SocialUserModel author;
  bool isSeen;

  StoryModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.expiresAt,
    required this.createdAt,
    required this.author,
    this.isSeen = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['Users'] as Map<String, dynamic>? ?? {};
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      author: SocialUserModel.fromJson(authorJson),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
