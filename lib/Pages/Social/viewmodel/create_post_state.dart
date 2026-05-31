import '../model/post_model.dart';

abstract class CreatePostState {}

class CreatePostInitial extends CreatePostState {}

class CreatePostUploading extends CreatePostState {}

class CreatePostSuccess extends CreatePostState {
  final PostModel post;
  CreatePostSuccess(this.post);
}

class CreatePostError extends CreatePostState {
  final String message;
  CreatePostError(this.message);
}
