import 'post_model.dart';
import 'social_user_model.dart';

class FeedItem {
  final PostModel post;
  final SocialUserModel? repostedBy;
  final DateTime sortDate;

  const FeedItem({
    required this.post,
    this.repostedBy,
    required this.sortDate,
  });

  bool get isRepost => repostedBy != null;

  FeedItem withPost(PostModel newPost) => FeedItem(
        post: newPost,
        repostedBy: repostedBy,
        sortDate: sortDate,
      );
}
