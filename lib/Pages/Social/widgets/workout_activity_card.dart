import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';
import '../../Dashboard/model/workout_detail_model.dart';
import '../../Dashboard/model/workout_history_model.dart';
import '../../WorkoutDetail/view/workout_detail_page.dart';
import '../model/post_model.dart';
import '../model/social_user_model.dart';

class WorkoutActivityCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  final SocialUserModel? repostedBy;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onDelete;

  const WorkoutActivityCard({
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
    final workout = post.workoutData;

    if (workout == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        final historyModel = WorkoutHistoryModel(
          id: workout.id,
          name: workout.name,
          date: workout.date,
          durationSeconds: workout.durationSeconds,
          exerciseCount: workout.exercises.length,
          totalSets: workout.totalSetsCount,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailPage(
              workout: historyModel,
              ownerName: post.author.username,
              ownerImageUrl: post.author.imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: (ref * 0.04).clamp(12.0, 20.0),
          vertical: (ref * 0.02).clamp(6.0, 10.0),
        ),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.border, width: 1.5),
          boxShadow: context.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repostedBy != null) _repostBanner(context, ref),
            _header(context, ref, avatarSize, isOwner),
            _workoutContent(context, ref, workout),
            _actions(context, ref),
          ],
        ),
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
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: (ref * 0.037).clamp(13.0, 15.0),
                      ),
                      children: [
                        TextSpan(
                          text: post.author.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' completed '),
                        TextSpan(
                          text: post.workoutData?.name ?? 'Workout',
                          style: TextStyle(
                            color: context.accentLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
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

  Widget _workoutContent(BuildContext context, double ref, WorkoutSessionDetail workout) {
    final horizontalPadding = (ref * 0.04).clamp(12.0, 20.0);

    // Stat items
    final durationMin = workout.durationSeconds ~/ 60;
    final totalVolume = workout.totalVolume;
    final totalSets = workout.totalSetsCount;
    final totalExercises = workout.exercises.length;

    // First 3 exercises
    final previewExercises = workout.exercises.take(3).toList();
    final remainingCount = totalExercises - previewExercises.length;

    // Progress data
    final summary = workout.progressSummary;
    final volumeDiff = summary?['volume_diff_pct'] as num?;
    final exerciseProgress = summary?['exercise_progress'] as List?;
    final hasProgress = (volumeDiff != null && volumeDiff > 0) || (exerciseProgress != null && exerciseProgress.isNotEmpty);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatChip(context, Icons.timer_outlined, '$durationMin min'),
                const SizedBox(width: 8),
                _buildStatChip(context, Icons.fitness_center_outlined, '$totalExercises exercises'),
                const SizedBox(width: 8),
                _buildStatChip(context, Icons.format_list_bulleted_outlined, '$totalSets sets'),
                if (totalVolume > 0) ...[
                  const SizedBox(width: 8),
                  _buildStatChip(context, Icons.scale_outlined, '${totalVolume % 1 == 0 ? totalVolume.toInt() : totalVolume.toStringAsFixed(1)} kg'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Exercise preview title / divider line
          Row(
            children: [
              Text(
                'Exercises Performed',
                style: TextStyle(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: context.divider, thickness: 1)),
            ],
          ),
          const SizedBox(height: 8),

          // Exercise items list
          ...previewExercises.map((ex) {
            final maxW = ex.maxWeight;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ex.name,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    maxW == 0
                        ? 'Bodyweight'
                        : '${maxW % 1 == 0 ? maxW.toInt() : maxW} kg',
                    style: TextStyle(
                      color: context.accentLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),

          if (remainingCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              '+$remainingCount more exercises',
              style: TextStyle(
                color: context.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Progress section
          if (hasProgress) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insights, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Progress Highlights',
                        style: TextStyle(
                          color: context.isDark ? Colors.green.shade300 : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (exerciseProgress != null)
                    ...exerciseProgress.map((item) {
                      final name = item['name'] as String;
                      final diff = item['diff'] as num;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Text('↑ ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' +${diff % 1 == 0 ? diff.toInt() : diff} kg',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ' since last session'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (volumeDiff != null && volumeDiff > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Text('↑ ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 12,
                                ),
                                children: [
                                  const TextSpan(text: 'Total volume '),
                                  TextSpan(
                                    text: '+$volumeDiff%',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.cardAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
