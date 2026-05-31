import 'package:flutter_bloc/flutter_bloc.dart';
import '../SocialRepository.dart';
import '../model/post_model.dart';
import 'saved_posts_state.dart';

class SavedPostsCubit extends Cubit<SavedPostsState> {
  final SocialRepository _repo;
  final String userId;

  List<PostModel> _posts = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  SavedPostsCubit(this._repo, {required this.userId})
      : super(SavedPostsInitial());

  Future<void> load() async {
    emit(SavedPostsLoading());
    try {
      _page = 0;
      _posts = await _repo.getSavedPosts(userId: userId, page: 0);
      _hasMore = _posts.length == 15;
      _emitLoaded();
    } catch (e) {
      emit(SavedPostsError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    try {
      _page++;
      final more = await _repo.getSavedPosts(userId: userId, page: _page);
      _posts = [..._posts, ...more];
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
    // If the post is currently saved, unsaving it removes it from the list of saved posts
    if (post.isSaved) {
      _posts = _posts.where((p) => p.id != post.id).toList();
      _emitLoaded();
      await _repo.unsavePost(postId: post.id, userId: userId);
    } else {
      // In case they want to re-save it before reloading
      final updated = post.copyWith(isSaved: true);
      _posts = [..._posts, updated];
      _emitLoaded();
      await _repo.savePost(postId: post.id, userId: userId);
    }
  }

  Future<void> toggleRepost(PostModel post) async {
    final updated = post.isReposted
        ? post.copyWith(isReposted: false, repostsCount: (post.repostsCount - 1).clamp(0, 999999))
        : post.copyWith(isReposted: true, repostsCount: post.repostsCount + 1);
    _updatePost(updated);
    _emitLoaded();

    if (post.isReposted) {
      await _repo.unrepostPost(postId: post.id, userId: userId);
    } else {
      await _repo.repostPost(postId: post.id, userId: userId);
    }
  }

  void incrementCommentCount(String postId) {
    _posts = _posts
        .map((post) => post.id == postId
            ? post.copyWith(commentsCount: post.commentsCount + 1)
            : post)
        .toList();
    _emitLoaded();
  }

  void _updatePost(PostModel updated) {
    _posts = _posts.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void _emitLoaded() {
    emit(SavedPostsLoaded(
      posts: List.from(_posts),
      hasMore: _hasMore,
    ));
  }
}
