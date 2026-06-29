import 'package:flutter/material.dart';
import '../model/post_model.dart';
import '../model/social_user_model.dart';
import 'post_card.dart';
import 'workout_activity_card.dart';

class FeedCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  final SocialUserModel? repostedBy;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onDelete;

  const FeedCard({
    super.key,
    required this.post,
    required this.currentUserId,
    this.repostedBy,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
    this.onAuthorTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (post.type == 'workout') {
      return WorkoutActivityCard(
        post: post,
        currentUserId: currentUserId,
        repostedBy: repostedBy,
        onLike: onLike,
        onComment: onComment,
        onSave: onSave,
        onShare: onShare,
        onAuthorTap: onAuthorTap,
        onDelete: onDelete,
      );
    }

    return PostCard(
      post: post,
      currentUserId: currentUserId,
      repostedBy: repostedBy,
      onLike: onLike,
      onComment: onComment,
      onSave: onSave,
      onShare: onShare,
      onAuthorTap: onAuthorTap,
      onDelete: onDelete,
    );
  }
}
