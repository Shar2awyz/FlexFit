import '../model/friendship_model.dart';

abstract class FriendRequestsState {}

class FriendRequestsInitial extends FriendRequestsState {}

class FriendRequestsLoading extends FriendRequestsState {}

class FriendRequestsLoaded extends FriendRequestsState {
  final List<FriendshipModel> requests;
  FriendRequestsLoaded(this.requests);
}

class FriendRequestsError extends FriendRequestsState {
  final String message;
  FriendRequestsError(this.message);
}
