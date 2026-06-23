import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flex_fit/Pages/Components/CustomBottomNavBar.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../model/story_model.dart';
import '../viewmodel/social_feed_cubit.dart';
import '../viewmodel/social_feed_state.dart';
import '../widgets/post_card.dart';
import '../widgets/story_circle.dart';
import 'AddByEmailPage.dart';
import 'CommentsPage.dart';
import 'CreatePostPage.dart';
import 'FriendProfilePage.dart';
import 'FriendRequestsPage.dart';
import 'SearchUsersPage.dart';
import 'StoryViewerPage.dart';

class SocialFeedPage extends StatelessWidget {
  final String currentUserId;
  final void Function(int)? onNavTap;

  const SocialFeedPage({super.key, required this.currentUserId, this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SocialFeedCubit(SocialRepository(), userId: currentUserId)..load(),
      child: _SocialFeedView(currentUserId: currentUserId, onNavTap: onNavTap),
    );
  }
}

class _SocialFeedView extends StatefulWidget {
  final String currentUserId;
  final void Function(int)? onNavTap;
  const _SocialFeedView({required this.currentUserId, this.onNavTap});

  @override
  State<_SocialFeedView> createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<_SocialFeedView> {
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
      context.read<SocialFeedCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4,
        onTap: (i) {
          if (i == 4) return;
          if (widget.onNavTap != null) {
            widget.onNavTap!(i);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.accentLight,
        onPressed: _openCreatePost,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<SocialFeedCubit>().load(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _appBar(context, ref),
            BlocBuilder<SocialFeedCubit, SocialFeedState>(
              builder: (context, state) {
                if (state is SocialFeedLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is SocialFeedError) {
                  return SliverFillRemaining(
                    child: Center(
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
                                context.read<SocialFeedCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is SocialFeedLoaded) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i == 0) {
                          return _storiesRow(context, ref, state.stories, state.currentUserImageUrl);
                        }
                        final itemIndex = i - 1;
                        if (itemIndex == state.items.length) {
                          return state.hasMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox(height: 20);
                        }
                        if (itemIndex >= state.items.length) {
                          return const SizedBox.shrink();
                        }
                        final item = state.items[itemIndex];
                        final post = item.post;
                        final cubit = context.read<SocialFeedCubit>();
                        return PostCard(
                          post: post,
                          currentUserId: widget.currentUserId,
                          repostedBy: item.repostedBy,
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
                                  await SocialRepository()
                                      .deletePost(post.id);
                                  if (context.mounted) {
                                    cubit.load();
                                  }
                                }
                              : null,
                        );
                      },
                      childCount: state.items.length + 2,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, double ref) {
    return SliverAppBar(
      backgroundColor: context.appBarBg,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Social',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: (ref * 0.048).clamp(18.0, 22.0),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          tooltip: 'Add by email',
          onPressed: () => Navigator.push(
            context,
            appRoute(
              (_) => AddByEmailPage(currentUserId: widget.currentUserId),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white),
          tooltip: 'Search users',
          onPressed: () => Navigator.push(
            context,
            appRoute(
              (_) => SearchUsersPage(currentUserId: widget.currentUserId),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.people_outline_rounded, color: Colors.white),
          tooltip: 'Friend requests',
          onPressed: () => Navigator.push(
            context,
            appRoute(
              (_) => FriendRequestsPage(currentUserId: widget.currentUserId),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadStory() async {
    final xFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null || !mounted) return;
    final bytes = await xFile.readAsBytes();
    final ext = xFile.path.split('.').last;
    if (!mounted) return;
    context.read<SocialFeedCubit>().addStory(bytes, ext);
  }

  Widget _addStoryCircle(BuildContext context, double ref,
      List<StoryModel> stories, String? currentUserImageUrl) {
    final size = (ref * 0.17).clamp(60.0, 76.0);
    final myStories = stories
        .where((s) => s.userId == widget.currentUserId)
        .toList();
    final hasStory = myStories.isNotEmpty;
    final photoUrl =
        (hasStory ? myStories.first.author.imageUrl : null) ?? currentUserImageUrl;

    final allMySeen = myStories.every((s) => s.isSeen);

    return GestureDetector(
      onTap: hasStory
          ? () async {
              await Navigator.push(
                context,
                appRoute((_) => StoryViewerPage(
                  stories: myStories,
                  currentUserId: widget.currentUserId,
                  onAddStory: _pickAndUploadStory,
                )),
              );
              if (context.mounted) {
                context.read<SocialFeedCubit>().markStoriesSeen(
                      myStories.map((s) => s.id).toList(),
                    );
              }
            }
          : _pickAndUploadStory,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStory && !allMySeen
                      ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: hasStory && !allMySeen ? null : context.border,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.pageBg, width: 2),
                  ),
                  child: ClipOval(
                    child: photoUrl != null
                        ? Image.network(photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _storyPlaceholder(context))
                        : _storyPlaceholder(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.34,
                  height: size * 0.34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6),
                    border:
                        Border.all(color: context.pageBg, width: 1.5),
                  ),
                  child: Icon(Icons.add_rounded,
                      color: Colors.white, size: size * 0.22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: size,
            child: Text(
              'Your Story',
              style: TextStyle(
                fontSize: (ref * 0.025).clamp(9.0, 11.0),
                color: context.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyPlaceholder(BuildContext context) => Container(
        color: context.iconBg,
        child:
            Icon(Icons.person_rounded, color: context.textMuted, size: 28),
      );

  Widget _storiesRow(
    BuildContext context,
    double ref,
    List<StoryModel> stories,
    String? currentUserImageUrl,
  ) {
    final othersGrouped = _groupedByUser(
        stories.where((s) => s.userId != widget.currentUserId).toList());
    final height = (ref * 0.28).clamp(100.0, 120.0);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: (ref * 0.04).clamp(12.0, 20.0),
          vertical: 8,
        ),
        itemCount: othersGrouped.length + 1,
        separatorBuilder: (_, _) =>
            SizedBox(width: (ref * 0.03).clamp(8.0, 14.0)),
        itemBuilder: (context, i) {
          if (i == 0) return _addStoryCircle(context, ref, stories, currentUserImageUrl);
          final userStories = othersGrouped[i - 1];
          final allSeen = userStories.every((s) => s.isSeen);
          return StoryCircle(
            story: userStories.first,
            isSeen: allSeen,
            onTap: () async {
              await Navigator.push(
                context,
                appRoute(
                  (_) => StoryViewerPage(
                    stories: userStories,
                    currentUserId: widget.currentUserId,
                    initialIndex: 0,
                  ),
                ),
              );
              if (context.mounted) {
                context.read<SocialFeedCubit>().markStoriesSeen(
                      userStories.map((s) => s.id).toList(),
                    );
              }
            },
          );
        },
      ),
    );
  }

  List<List<StoryModel>> _groupedByUser(List<StoryModel> stories) {
    final map = <String, List<StoryModel>>{};
    for (final s in stories) {
      map.putIfAbsent(s.userId, () => []).add(s);
    }
    return map.values.toList();
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      appRoute(
        (_) => CreatePostPage(
          currentUserId: widget.currentUserId,
          onPostCreated: (post) =>
              context.read<SocialFeedCubit>().prependPost(post),
        ),
      ),
    );
  }
}
