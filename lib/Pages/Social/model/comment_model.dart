import 'social_user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String comment;
  final DateTime createdAt;
  final SocialUserModel author;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['Users'] as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: SocialUserModel.fromJson(authorJson),
    );
  }
}
