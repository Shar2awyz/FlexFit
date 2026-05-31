import '../model/friendship_model.dart';
import '../model/social_user_model.dart';

abstract class AddByEmailState {}

class AddByEmailInitial extends AddByEmailState {}

class AddByEmailSearching extends AddByEmailState {}

class AddByEmailNotFound extends AddByEmailState {}

class AddByEmailFound extends AddByEmailState {
  final SocialUserModel user;
  final FriendshipStatus status;

  AddByEmailFound({required this.user, required this.status});
}

class AddByEmailError extends AddByEmailState {
  final String message;
  AddByEmailError(this.message);
}
