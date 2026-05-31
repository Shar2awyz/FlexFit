import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled6/Pages/Components/app_route.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../model/friendship_model.dart';
import '../viewmodel/friend_profile_cubit.dart';
import '../viewmodel/friend_profile_state.dart';
import '../widgets/post_card.dart';
import 'CommentsPage.dart';

class FriendProfilePage extends StatelessWidget {
  final String currentUserId;
  final String profileUserId;

  const FriendProfilePage({
    super.key,
    required this.currentUserId,
    required this.profileUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendProfileCubit(
        SocialRepository(),
        currentUserId: currentUserId,
        profileUserId: profileUserId,
      )..load(),
      child: _FriendProfileView(currentUserId: currentUserId),
    );
  }
}

class _FriendProfileView extends StatelessWidget {
  final String currentUserId;

  const _FriendProfileView({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      body: BlocBuilder<FriendProfileCubit, FriendProfileState>(
        builder: (context, state) {
          if (state is FriendProfileLoading || state is FriendProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FriendProfileError) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: context.appBarBg,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: Text(state.message,
                    style: TextStyle(color: context.textMuted)),
              ),
            );
          }
          if (state is FriendProfileLoaded) {
            return CustomScrollView(
              slivers: [
                _appBar(context, ref, state),
                SliverToBoxAdapter(
                  child: _profileHeader(context, ref, state),
                ),
                if (state.posts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text('No posts yet',
                          style: TextStyle(color: context.textMuted)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i == state.posts.length) {
                          if (state.hasMore) {
                            context
                                .read<FriendProfileCubit>()
                                .loadMorePosts();
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          return const SizedBox(height: 20);
                        }
                        final post = state.posts[i];
                        return PostCard(
                          post: post,
                          currentUserId: currentUserId,
                          onLike: () {},
                          onSave: () {},
                          onShare: () {},
                          onComment: () => Navigator.push(
                            context,
                            appRoute(
                              (_) => CommentsPage(
                                postId: post.id,
                                currentUserId: currentUserId,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.posts.length + 1,
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _appBar(
    BuildContext context,
    double ref,
    FriendProfileLoaded state,
  ) {
    return SliverAppBar(
      backgroundColor: context.appBarBg,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        state.user.username,
        style: const TextStyle(color: Colors.white),
      ),
      pinned: true,
      elevation: 0,
    );
  }

  Widget _profileHeader(
    BuildContext context,
    double ref,
    FriendProfileLoaded state,
  ) {
    final avatarSize = (ref * 0.22).clamp(76.0, 96.0);
    final isOwnProfile = currentUserId == state.user.id;

    return Container(
      padding: EdgeInsets.all((ref * 0.05).clamp(16.0, 24.0)),
      child: Column(
        children: [
          ClipOval(
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: state.user.imageUrl != null
                  ? Image.network(
                      state.user.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _avatarPlaceholder(context, avatarSize),
                    )
                  : _avatarPlaceholder(context, avatarSize),
            ),
          ),
          SizedBox(height: (ref * 0.03).clamp(10.0, 16.0)),
          Text(
            state.user.username,
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: (ref * 0.05).clamp(18.0, 22.0),
            ),
          ),
          SizedBox(height: (ref * 0.03).clamp(10.0, 16.0)),
          if (!isOwnProfile) _friendshipButton(context, ref, state),
        ],
      ),
    );
  }

  Widget _friendshipButton(
    BuildContext context,
    double ref,
    FriendProfileLoaded state,
  ) {
    final cubit = context.read<FriendProfileCubit>();

    switch (state.friendshipStatus) {
      case FriendshipStatus.none:
        return _btn(
          context: context,
          ref: ref,
          label: 'Add Friend',
          icon: Icons.person_add_rounded,
          color: context.accentLight,
          onTap: cubit.sendRequest,
        );
      case FriendshipStatus.pending:
        return _btn(
          context: context,
          ref: ref,
          label: 'Request Sent',
          icon: Icons.hourglass_top_rounded,
          color: context.textMuted,
          onTap: cubit.removeFriend,
        );
      case FriendshipStatus.accepted:
        return _btn(
          context: context,
          ref: ref,
          label: 'Friends',
          icon: Icons.people_rounded,
          color: Colors.green,
          onTap: () => _confirmRemove(context, cubit),
        );
      case FriendshipStatus.rejected:
        return _btn(
          context: context,
          ref: ref,
          label: 'Add Friend',
          icon: Icons.person_add_rounded,
          color: context.accentLight,
          onTap: cubit.sendRequest,
        );
    }
  }

  Widget _btn({
    required BuildContext context,
    required double ref,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (ref * 0.06).clamp(20.0, 32.0),
          vertical: (ref * 0.025).clamp(8.0, 12.0),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: (ref * 0.036).clamp(13.0, 15.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, FriendProfileCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text('Remove Friend',
            style: TextStyle(color: context.textPrimary)),
        content: Text('Are you sure you want to remove this friend?',
            style: TextStyle(color: context.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: context.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.removeFriend();
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.iconBg,
      child: Icon(Icons.person_rounded, color: context.textMuted, size: size * 0.5),
    );
  }
}
