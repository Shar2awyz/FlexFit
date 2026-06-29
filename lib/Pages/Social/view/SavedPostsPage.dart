import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../viewmodel/saved_posts_cubit.dart';
import '../viewmodel/saved_posts_state.dart';
import '../widgets/feed_card.dart';
import 'CommentsPage.dart';
import 'FriendProfilePage.dart';

class SavedPostsPage extends StatelessWidget {
  final String currentUserId;

  const SavedPostsPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SavedPostsCubit(SocialRepository(), userId: currentUserId)..load(),
      child: SavedPostsView(currentUserId: currentUserId),
    );
  }
}

class SavedPostsView extends StatefulWidget {
  final String currentUserId;
  const SavedPostsView({super.key, required this.currentUserId});

  @override
  State<SavedPostsView> createState() => _SavedPostsViewState();
}

class _SavedPostsViewState extends State<SavedPostsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<SavedPostsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Posts',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<SavedPostsCubit>().load(),
        child: BlocBuilder<SavedPostsCubit, SavedPostsState>(
          builder: (context, state) {
            if (state is SavedPostsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SavedPostsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 48, color: context.textMuted),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: TextStyle(color: context.textMuted)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<SavedPostsCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is SavedPostsLoaded) {
              if (state.posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: context.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved posts yet',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posts you save will appear here',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: state.posts.length + 1,
                itemBuilder: (context, i) {
                  if (i == state.posts.length) {
                    return state.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator()),
                          )
                        : const SizedBox(height: 20);
                  }
                  final post = state.posts[i];
                  final cubit = context.read<SavedPostsCubit>();

                  return FeedCard(
                    post: post,
                    currentUserId: widget.currentUserId,
                    onLike: () => cubit.toggleLike(post),
                    onSave: () => cubit.toggleSave(post),
                    onShare: () => cubit.toggleRepost(post),
                    onComment: () => Navigator.push(
                      context,
                      appRoute(
                        (_) => CommentsPage(
                          postId: post.id,
                          currentUserId: widget.currentUserId,
                          onCommentAdded: () =>
                              cubit.incrementCommentCount(post.id),
                        ),
                      ),
                    ),
                    onAuthorTap: post.userId != widget.currentUserId
                        ? () => Navigator.push(
                              context,
                              appRoute(
                                (_) => FriendProfilePage(
                                  currentUserId: widget.currentUserId,
                                  profileUserId: post.userId,
                                ),
                              ),
                            )
                        : null,
                    onDelete: post.userId == widget.currentUserId
                        ? () async {
                            await SocialRepository().deletePost(post.id);
                            if (context.mounted) {
                              cubit.load();
                            }
                          }
                        : null,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
