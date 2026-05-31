import '../model/post_model.dart';

abstract class SavedPostsState {}

class SavedPostsInitial extends SavedPostsState {}

class SavedPostsLoading extends SavedPostsState {}

class SavedPostsLoaded extends SavedPostsState {
  final List<PostModel> posts;
  final bool hasMore;

  SavedPostsLoaded({
    required this.posts,
    this.hasMore = true,
  });
}

class SavedPostsError extends SavedPostsState {
  final String message;
  SavedPostsError(this.message);
}
