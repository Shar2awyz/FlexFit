import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../viewmodel/comments_cubit.dart';
import '../viewmodel/comments_state.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final VoidCallback? onCommentAdded;

  const CommentsPage({
    super.key,
    required this.postId,
    required this.currentUserId,
    this.onCommentAdded,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommentsCubit(
        SocialRepository(),
        postId: widget.postId,
        userId: widget.currentUserId,
      )..load(),
      child: _CommentsView(
        currentUserId: widget.currentUserId,
        onCommentAdded: widget.onCommentAdded,
      ),
    );
  }
}

class _CommentsView extends StatefulWidget {
  final String currentUserId;
  final VoidCallback? onCommentAdded;

  const _CommentsView({required this.currentUserId, this.onCommentAdded});

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        title: const Text('Comments', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CommentsError) {
                  return Center(
                    child: Text(state.message, style: TextStyle(color: context.textMuted)),
                  );
                }
                if (state is CommentsLoaded) {
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(color: context.textMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all((ref * 0.04).clamp(12.0, 20.0)),
                    itemCount: state.comments.length,
                    itemBuilder: (context, i) {
                      final c = state.comments[i];
                      final isOwner = c.userId == widget.currentUserId;
                      return Dismissible(
                        key: Key(c.id),
                        direction: isOwner
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        onDismissed: (_) =>
                            context.read<CommentsCubit>().deleteComment(c.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all((ref * 0.035).clamp(10.0, 14.0)),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: context.cardShadow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: (ref * 0.09).clamp(32.0, 40.0),
                                  height: (ref * 0.09).clamp(32.0, 40.0),
                                  child: c.author.imageUrl != null
                                      ? Image.network(c.author.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _placeholder(context, ref))
                                      : _placeholder(context, ref),
                                ),
                              ),
                              SizedBox(width: (ref * 0.03).clamp(8.0, 12.0)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.author.username,
                                      style: TextStyle(
                                        color: context.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: (ref * 0.034).clamp(12.0, 14.0),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.comment,
                                      style: TextStyle(
                                        color: context.textSecondary,
                                        fontSize: (ref * 0.036).clamp(13.0, 15.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _inputBar(context, ref),
        ],
      ),
    );
  }

  Widget _inputBar(BuildContext context, double ref) {
    return Container(
      color: context.cardBg,
      padding: EdgeInsets.fromLTRB(
        (ref * 0.04).clamp(12.0, 20.0),
        10,
        8,
        MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(color: context.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.innerCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _sending
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  onPressed: _submit,
                  icon: Icon(Icons.send_rounded, color: context.accentLight),
                ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await context.read<CommentsCubit>().addComment(text);
    _controller.clear();
    widget.onCommentAdded?.call();
    if (mounted) setState(() => _sending = false);
  }

  Widget _placeholder(BuildContext context, double ref) {
    return Container(
      color: context.iconBg,
      child: Icon(Icons.person_rounded, color: context.textMuted,
          size: (ref * 0.05).clamp(18.0, 24.0)),
    );
  }
}
