import 'package:flutter_bloc/flutter_bloc.dart';

import '../SocialRepository.dart';
import '../model/friendship_model.dart';
import 'add_by_email_state.dart';

class AddByEmailCubit extends Cubit<AddByEmailState> {
  final SocialRepository _repo;
  final String currentUserId;

  AddByEmailCubit(this._repo, {required this.currentUserId})
      : super(AddByEmailInitial());

  Future<void> findByEmail(String email) async {
    if (email.trim().isEmpty) return;
    emit(AddByEmailSearching());
    try {
      final user = await _repo.findUserByEmail(
        email: email,
        currentUserId: currentUserId,
      );
      if (user == null) {
        emit(AddByEmailNotFound());
        return;
      }
      final status = await _repo.checkFriendship(currentUserId, user.id);
      emit(AddByEmailFound(user: user, status: status));
    } catch (e) {
      emit(AddByEmailError(e.toString()));
    }
  }

  Future<void> sendRequest(String addresseeId) async {
    final current = state;
    if (current is! AddByEmailFound) return;
    try {
      await _repo.sendFriendRequest(
        requesterId: currentUserId,
        addresseeId: addresseeId,
      );
      emit(AddByEmailFound(user: current.user, status: FriendshipStatus.pending));
    } catch (e) {
      emit(AddByEmailError(e.toString()));
    }
  }

  Future<void> cancelRequest(String otherUserId) async {
    final current = state;
    if (current is! AddByEmailFound) return;
    try {
      final friendshipId = await _repo.getFriendshipId(currentUserId, otherUserId);
      if (friendshipId != null) {
        await _repo.removeFriend(friendshipId);
      }
      emit(AddByEmailFound(user: current.user, status: FriendshipStatus.none));
    } catch (e) {
      emit(AddByEmailError(e.toString()));
    }
  }

  void reset() => emit(AddByEmailInitial());
}
