import 'package:flutter_bloc/flutter_bloc.dart';

import '../SocialRepository.dart';
import '../model/comment_model.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final SocialRepository _repo;
  final String postId;
  final String userId;

  List<CommentModel> _comments = [];

  CommentsCubit(this._repo, {required this.postId, required this.userId})
      : super(CommentsInitial());

  Future<void> load() async {
    emit(CommentsLoading());
    try {
      _comments = await _repo.getComments(postId);
      emit(CommentsLoaded(List.from(_comments)));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) return;
    try {
      final comment = await _repo.addComment(
        postId: postId,
        userId: userId,
        comment: content.trim(),
      );
      _comments.add(comment);
      emit(CommentsLoaded(List.from(_comments)));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> deleteComment(String commentId) async {
    _comments.removeWhere((c) => c.id == commentId);
    emit(CommentsLoaded(List.from(_comments)));
    await _repo.deleteComment(commentId);
  }
}
