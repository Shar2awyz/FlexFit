import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../SocialRepository.dart';
import '../model/feed_item.dart';
import '../model/post_model.dart';
import '../model/story_model.dart';
import 'social_feed_state.dart';

class SocialFeedCubit extends Cubit<SocialFeedState> {
  final SocialRepository _repo;
  final String userId;

  List<StoryModel> _stories = [];
  List<FeedItem> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;
  String? _currentUserImageUrl;

  SocialFeedCubit(this._repo, {required this.userId})
      : super(SocialFeedInitial());

  Future<void> load() async {
    emit(SocialFeedLoading());
    try {
      _page = 0;
      _stories = await _repo.getStories(userId);
      _items = await _repo.getFeed(userId: userId, page: 0);
      _hasMore = _items.length == 15;
      try {
        final profile = await _repo.getUserProfile(userId);
        _currentUserImageUrl = profile.imageUrl;
      } catch (_) {}
      _emitLoaded();
    } catch (e) {
      emit(SocialFeedError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    try {
      _page++;
      final more = await _repo.getFeed(userId: userId, page: _page);
      _items = [..._items, ...more];
      _hasMore = more.length == 15;
      _emitLoaded();
    } catch (_) {
      _page--;
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final updated = post.isLiked
        ? post.copyWith(isLiked: false, likesCount: post.likesCount - 1)
        : post.copyWith(isLiked: true, likesCount: post.likesCount + 1);
    _updatePost(updated);
    _emitLoaded();

    if (post.isLiked) {
      await _repo.unlikePost(postId: post.id, userId: userId);
    } else {
      await _repo.likePost(postId: post.id, userId: userId);
    }
  }

  Future<void> toggleSave(PostModel post) async {
    _updatePost(post.copyWith(isSaved: !post.isSaved));
    _emitLoaded();

    if (post.isSaved) {
      await _repo.unsavePost(postId: post.id, userId: userId);
    } else {
      await _repo.savePost(postId: post.id, userId: userId);
    }
  }

  Future<void> toggleRepost(PostModel post) async {
    if (post.isReposted) {
      // Optimistic: remove the current user's repost entry from feed + decrement count
      _items = _items
          .where((item) =>
              !(item.isRepost &&
                  item.post.id == post.id &&
                  item.repostedBy?.id == userId))
          .toList();
      _updatePost(post.copyWith(
        isReposted: false,
        repostsCount: (post.repostsCount - 1).clamp(0, 999999),
      ));
      _emitLoaded();
      await _repo.unrepostPost(postId: post.id, userId: userId);
    } else {
      _updatePost(
          post.copyWith(isReposted: true, repostsCount: post.repostsCount + 1));
      _emitLoaded();
      await _repo.repostPost(postId: post.id, userId: userId);
    }
  }

  void incrementCommentCount(String postId) {
    _items = _items
        .map((item) => item.post.id == postId
            ? item.withPost(item.post
                .copyWith(commentsCount: item.post.commentsCount + 1))
            : item)
        .toList();
    _emitLoaded();
  }

  void prependPost(PostModel post) {
    _items = [FeedItem(post: post, sortDate: post.createdAt), ..._items];
    _emitLoaded();
  }

  Future<void> addStory(Uint8List bytes, String ext) async {
    try {
      final url = await _repo.uploadStoryImage(userId, bytes, ext);
      await _repo.createStory(userId: userId, imageUrl: url ?? '');
      _stories = await _repo.getStories(userId);
      _emitLoaded();
    } catch (_) {}
  }

  void markStoriesSeen(List<String> storyIds) {
    bool changed = false;
    for (final s in _stories) {
      if (storyIds.contains(s.id) && !s.isSeen) {
        s.isSeen = true;
        changed = true;
      }
    }
    if (changed) {
      _emitLoaded();
    }
  }

  // Updates every FeedItem that wraps the given post (original + any repost copies)
  void _updatePost(PostModel updated) {
    _items = _items
        .map((item) =>
            item.post.id == updated.id ? item.withPost(updated) : item)
        .toList();
  }

  void _emitLoaded() {
    emit(SocialFeedLoaded(
      stories: _stories,
      items: List.from(_items),
      hasMore: _hasMore,
      currentUserImageUrl: _currentUserImageUrl,
    ));
  }
}
