import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../model/post_model.dart';
import '../viewmodel/create_post_cubit.dart';
import '../viewmodel/create_post_state.dart';

class CreatePostPage extends StatelessWidget {
  final String currentUserId;
  final void Function(PostModel post)? onPostCreated;

  const CreatePostPage({
    super.key,
    required this.currentUserId,
    this.onPostCreated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreatePostCubit(SocialRepository(), userId: currentUserId),
      child: _CreatePostView(onPostCreated: onPostCreated),
    );
  }
}

class _CreatePostView extends StatefulWidget {
  final void Function(PostModel post)? onPostCreated;
  const _CreatePostView({this.onPostCreated});

  @override
  State<_CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<_CreatePostView> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return BlocListener<CreatePostCubit, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          widget.onPostCreated?.call(state.post);
          Navigator.pop(context);
        } else if (state is CreatePostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          iconTheme: const IconThemeData(color: Colors.white),
          title:
              const Text('New Post', style: TextStyle(color: Colors.white)),
          elevation: 0,
          actions: [
            BlocBuilder<CreatePostCubit, CreatePostState>(
              builder: (context, state) {
                final loading = state is CreatePostUploading;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : TextButton(
                          onPressed: _submit,
                          child: Text(
                            'Post',
                            style: TextStyle(
                              color: context.accentLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all((ref * 0.04).clamp(14.0, 22.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageSection(context, ref),
              SizedBox(height: (ref * 0.04).clamp(14.0, 20.0)),
              TextField(
                controller: _captionController,
                maxLines: 5,
                minLines: 3,
                style: TextStyle(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Write a caption…',
                  hintStyle: TextStyle(color: context.textMuted),
                  filled: true,
                  fillColor: context.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSection(BuildContext context, double ref) {
    final height = (ref * 0.55).clamp(180.0, 260.0);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.border,
            width: 1.5,
          ),
          boxShadow: context.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: _pickedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb
                      ? Image.network(
                          _pickedImage!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(context),
                        )
                      : Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(context),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              )
            : _imagePlaceholder(context),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_rounded,
            size: 48, color: context.textMuted),
        const SizedBox(height: 8),
        Text(
          'Tap to add a photo',
          style: TextStyle(color: context.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _pickedImage = image);
      if (mounted) context.read<CreatePostCubit>().setImage(image);
    }
  }

  void _removeImage() {
    setState(() => _pickedImage = null);
    context.read<CreatePostCubit>().setImage(null);
  }

  void _submit() {
    context
        .read<CreatePostCubit>()
        .submit(_captionController.text);
  }
}
