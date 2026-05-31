import '../model/social_user_model.dart';

abstract class SearchUsersState {}

class SearchUsersInitial extends SearchUsersState {}

class SearchUsersLoading extends SearchUsersState {}

class SearchUsersLoaded extends SearchUsersState {
  final List<SocialUserModel> users;
  SearchUsersLoaded(this.users);
}

class SearchUsersError extends SearchUsersState {
  final String message;
  SearchUsersError(this.message);
}
