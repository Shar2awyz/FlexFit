import 'package:flutter_bloc/flutter_bloc.dart';

import '../SocialRepository.dart';
import '../model/friendship_model.dart';
import 'friend_requests_state.dart';

class FriendRequestsCubit extends Cubit<FriendRequestsState> {
  final SocialRepository _repo;
  final String userId;

  List<FriendshipModel> _requests = [];

  FriendRequestsCubit(this._repo, {required this.userId})
      : super(FriendRequestsInitial());

  Future<void> load() async {
    emit(FriendRequestsLoading());
    try {
      _requests = await _repo.getPendingRequests(userId);
      emit(FriendRequestsLoaded(List.from(_requests)));
    } catch (e) {
      emit(FriendRequestsError(e.toString()));
    }
  }

  Future<void> accept(String friendshipId) async {
    await _repo.acceptFriendRequest(friendshipId);
    _requests.removeWhere((r) => r.id == friendshipId);
    emit(FriendRequestsLoaded(List.from(_requests)));
  }

  Future<void> reject(String friendshipId) async {
    await _repo.rejectFriendRequest(friendshipId);
    _requests.removeWhere((r) => r.id == friendshipId);
    emit(FriendRequestsLoaded(List.from(_requests)));
  }
}
