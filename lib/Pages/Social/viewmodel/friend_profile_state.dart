import '../model/friendship_model.dart';
import '../model/post_model.dart';
import '../model/social_user_model.dart';

abstract class FriendProfileState {}

class FriendProfileInitial extends FriendProfileState {}

class FriendProfileLoading extends FriendProfileState {}

class FriendProfileLoaded extends FriendProfileState {
  final SocialUserModel user;
  final FriendshipStatus friendshipStatus;
  final String? friendshipId;
  final List<PostModel> posts;
  final bool hasMore;

  FriendProfileLoaded({
    required this.user,
    required this.friendshipStatus,
    this.friendshipId,
    required this.posts,
    this.hasMore = true,
  });
}

class FriendProfileError extends FriendProfileState {
  final String message;
  FriendProfileError(this.message);
}
