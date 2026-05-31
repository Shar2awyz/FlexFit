import 'package:flutter_bloc/flutter_bloc.dart';

import '../SocialRepository.dart';
import 'search_users_state.dart';

class SearchUsersCubit extends Cubit<SearchUsersState> {
  final SocialRepository _repo;
  final String currentUserId;

  SearchUsersCubit(this._repo, {required this.currentUserId})
      : super(SearchUsersInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchUsersInitial());
      return;
    }
    emit(SearchUsersLoading());
    try {
      final users = await _repo.searchUsers(
        query: query.trim(),
        currentUserId: currentUserId,
      );
      emit(SearchUsersLoaded(users));
    } catch (e) {
      emit(SearchUsersError(e.toString()));
    }
  }
}
