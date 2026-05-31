import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../model/post_model.dart';
import '../model/social_user_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  final SocialUserModel? repostedBy;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onDelete;

  const PostCard({
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
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);
    final avatarSize = (ref * 0.1).clamp(36.0, 46.0);
    final isOwner = post.userId == currentUserId;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: (ref * 0.04).clamp(12.0, 20.0),
        vertical: (ref * 0.02).clamp(6.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (repostedBy != null) _repostBanner(context, ref),
          _header(context, ref, avatarSize, isOwner),
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (ref * 0.04).clamp(12.0, 20.0),
                vertical: 8,
              ),
              child: Text(
                post.caption!,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: (ref * 0.038).clamp(13.0, 16.0),
                  height: 1.45,
                ),
              ),
            ),
          if (post.imageUrl != null) _image(ref),
          _actions(context, ref),
        ],
      ),
    );
  }

  Widget _repostBanner(BuildContext context, double ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (ref * 0.04).clamp(12.0, 20.0),
        (ref * 0.025).clamp(8.0, 12.0),
        (ref * 0.04).clamp(12.0, 20.0),
        4,
      ),
      child: Row(
        children: [
          Icon(
            Icons.repeat_rounded,
            size: (ref * 0.038).clamp(14.0, 17.0),
            color: context.textMuted,
          ),
          const SizedBox(width: 6),
          if (repostedBy!.imageUrl != null)
            ClipOval(
              child: SizedBox(
                width: (ref * 0.055).clamp(18.0, 22.0),
                height: (ref * 0.055).clamp(18.0, 22.0),
                child: Image.network(
                  repostedBy!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          if (repostedBy!.imageUrl != null) const SizedBox(width: 5),
          Expanded(
            child: Text(
              '${repostedBy!.username} reposted',
              style: TextStyle(
                color: context.textMuted,
                fontSize: (ref * 0.032).clamp(11.0, 13.0),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(
    BuildContext context,
    double ref,
    double avatarSize,
    bool isOwner,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (ref * 0.04).clamp(12.0, 20.0),
        (ref * 0.035).clamp(12.0, 16.0),
        8,
        8,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAuthorTap,
            child: ClipOval(
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: post.author.imageUrl != null
                    ? Image.network(
                        post.author.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _avatarPlaceholder(context, avatarSize),
                      )
                    : _avatarPlaceholder(context, avatarSize),
              ),
            ),
          ),
          SizedBox(width: (ref * 0.03).clamp(8.0, 12.0)),
          Expanded(
            child: GestureDetector(
              onTap: onAuthorTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author.username,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: (ref * 0.037).clamp(13.0, 15.0),
                    ),
                  ),
                  Text(
                    _timeAgo(post.createdAt),
                    style: TextStyle(
                      color: context.textMuted,
                      fontSize: (ref * 0.028).clamp(10.0, 12.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOwner && onDelete != null)
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: context.textMuted),
              onPressed: () => _showDeleteSheet(context),
            ),
        ],
      ),
    );
  }

  Widget _image(double ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: (ref * 0.04).clamp(12.0, 20.0)),
        child: Image.network(
          post.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, double ref) {
    final iconSize = (ref * 0.055).clamp(20.0, 26.0);
    final fontSize = (ref * 0.032).clamp(11.0, 13.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        (ref * 0.02).clamp(6.0, 12.0),
        4,
        (ref * 0.02).clamp(6.0, 12.0),
        (ref * 0.03).clamp(8.0, 12.0),
      ),
      child: Row(
        children: [
          _actionBtn(
            context: context,
            icon: post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: post.isLiked ? Colors.redAccent : context.textMuted,
            label: '${post.likesCount}',
            iconSize: iconSize,
            fontSize: fontSize,
            onTap: onLike,
          ),
          SizedBox(width: (ref * 0.04).clamp(12.0, 20.0)),
          _actionBtn(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            color: context.textMuted,
            label: '${post.commentsCount}',
            iconSize: iconSize,
            fontSize: fontSize,
            onTap: onComment,
          ),
          SizedBox(width: (ref * 0.04).clamp(12.0, 20.0)),
          _actionBtn(
            context: context,
            icon: Icons.repeat_rounded,
            color: post.isReposted ? Colors.green : context.textMuted,
            label: '${post.repostsCount}',
            iconSize: iconSize,
            fontSize: fontSize,
            onTap: onShare,
          ),
          const Spacer(),
          _actionBtn(
            context: context,
            icon: post.isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: post.isSaved ? context.accentLight : context.textMuted,
            label: '',
            iconSize: iconSize,
            fontSize: fontSize,
            onTap: onSave,
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required double iconSize,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: iconSize),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style:
                  TextStyle(color: context.textSecondary, fontSize: fontSize),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.iconBg,
      child: Icon(Icons.person_rounded, color: context.textMuted),
    );
  }

  void _showDeleteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: ListTile(
          leading:
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          title: const Text('Delete post'),
          onTap: () {
            Navigator.pop(context);
            onDelete?.call();
          },
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
