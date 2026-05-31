import 'package:flutter_bloc/flutter_bloc.dart';

import '../SocialRepository.dart';
import '../model/friendship_model.dart';
import '../model/post_model.dart';
import '../model/social_user_model.dart';
import 'friend_profile_state.dart';

class FriendProfileCubit extends Cubit<FriendProfileState> {
  final SocialRepository _repo;
  final String currentUserId;
  final String profileUserId;

  SocialUserModel? _user;
  FriendshipStatus _status = FriendshipStatus.none;
  String? _friendshipId;
  List<PostModel> _posts = [];
  int _page = 0;
  bool _hasMore = true;

  FriendProfileCubit(
    this._repo, {
    required this.currentUserId,
    required this.profileUserId,
  }) : super(FriendProfileInitial());

  Future<void> load() async {
    emit(FriendProfileLoading());
    try {
      _page = 0;
      _user = await _repo.getUserProfile(profileUserId);
      _status = await _repo.checkFriendship(currentUserId, profileUserId);
      _friendshipId = await _repo.getFriendshipId(currentUserId, profileUserId);
      _posts = await _repo.getUserPosts(
        profileUserId: profileUserId,
        currentUserId: currentUserId,
        page: 0,
      );
      _hasMore = _posts.length == 15;
      _emitLoaded();
    } catch (e) {
      emit(FriendProfileError(e.toString()));
    }
  }

  Future<void> loadMorePosts() async {
    if (!_hasMore) return;
    try {
      _page++;
      final more = await _repo.getUserPosts(
        profileUserId: profileUserId,
        currentUserId: currentUserId,
        page: _page,
      );
      _posts = [..._posts, ...more];
      _hasMore = more.length == 15;
      _emitLoaded();
    } catch (_) {
      _page--;
    }
  }

  Future<void> sendRequest() async {
    await _repo.sendFriendRequest(
      requesterId: currentUserId,
      addresseeId: profileUserId,
    );
    _friendshipId = await _repo.getFriendshipId(currentUserId, profileUserId);
    _status = FriendshipStatus.pending;
    _emitLoaded();
  }

  Future<void> removeFriend() async {
    if (_friendshipId == null) return;
    await _repo.removeFriend(_friendshipId!);
    _status = FriendshipStatus.none;
    _friendshipId = null;
    _posts = await _repo.getUserPosts(
      profileUserId: profileUserId,
      currentUserId: currentUserId,
      page: 0,
    );
    _emitLoaded();
  }

  void _emitLoaded() {
    if (_user == null) return;
    emit(FriendProfileLoaded(
      user: _user!,
      friendshipStatus: _status,
      friendshipId: _friendshipId,
      posts: List.from(_posts),
      hasMore: _hasMore,
    ));
  }
}
