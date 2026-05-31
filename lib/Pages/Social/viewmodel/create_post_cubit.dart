import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../SocialRepository.dart';
import 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  final SocialRepository _repo;
  final String userId;

  XFile? pickedImage;

  CreatePostCubit(this._repo, {required this.userId})
      : super(CreatePostInitial());

  void setImage(XFile? image) {
    pickedImage = image;
  }

  Future<void> submit(String? caption) async {
    if ((caption == null || caption.trim().isEmpty) && pickedImage == null) {
      emit(CreatePostError('Add a caption or image.'));
      return;
    }
    emit(CreatePostUploading());
    try {
      String? imageUrl;
      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();
        final ext = pickedImage!.name.split('.').last;
        imageUrl = await _repo.uploadPostImage(
          userId,
          Uint8List.fromList(bytes),
          ext,
        );
      }
      final post = await _repo.createPost(
        userId: userId,
        caption: caption?.trim(),
        imageUrl: imageUrl,
      );
      emit(CreatePostSuccess(post));
    } catch (e) {
      emit(CreatePostError(e.toString()));
    }
  }
}
