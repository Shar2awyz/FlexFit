import 'social_user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? caption;
  final String? imageUrl;
  final DateTime createdAt;
  final SocialUserModel author;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final bool isLiked;
  final bool isSaved;
  final bool isReposted;

  const PostModel({
    required this.id,
    required this.userId,
    this.caption,
    this.imageUrl,
    required this.createdAt,
    required this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isReposted = false,
  });

  factory PostModel.fromJson(
    Map<String, dynamic> json, {
    bool isLiked = false,
    bool isSaved = false,
    bool isReposted = false,
  }) {
    final authorJson = json['Users'] as Map<String, dynamic>? ?? {};

    final likesList = json['post_likes'] as List?;
    final commentsList = json['post_comments'] as List?;
    final repostsList = json['post_reposts'] as List?;

    final likesCount =
        (likesList?.isNotEmpty == true ? likesList!.first['count'] : 0)
            as int? ?? 0;
    final commentsCount =
        (commentsList?.isNotEmpty == true ? commentsList!.first['count'] : 0)
            as int? ?? 0;
    final repostsCount =
        (repostsList?.isNotEmpty == true ? repostsList!.first['count'] : 0)
            as int? ?? 0;

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      caption: json['caption'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: SocialUserModel.fromJson(authorJson),
      likesCount: likesCount,
      commentsCount: commentsCount,
      repostsCount: repostsCount,
      isLiked: isLiked,
      isSaved: isSaved,
      isReposted: isReposted,
    );
  }

  PostModel copyWith({
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    bool? isLiked,
    bool? isSaved,
    bool? isReposted,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      caption: caption,
      imageUrl: imageUrl,
      createdAt: createdAt,
      author: author,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isReposted: isReposted ?? this.isReposted,
    );
  }
}
