import '../model/feed_item.dart';
import '../model/story_model.dart';

abstract class SocialFeedState {}

class SocialFeedInitial extends SocialFeedState {}

class SocialFeedLoading extends SocialFeedState {}

class SocialFeedLoaded extends SocialFeedState {
  final List<StoryModel> stories;
  final List<FeedItem> items;
  final bool hasMore;
  final String? currentUserImageUrl;

  SocialFeedLoaded({
    required this.stories,
    required this.items,
    this.hasMore = true,
    this.currentUserImageUrl,
  });
}

class SocialFeedError extends SocialFeedState {
  final String message;
  SocialFeedError(this.message);
}
