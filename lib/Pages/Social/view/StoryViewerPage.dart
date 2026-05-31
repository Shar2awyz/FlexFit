import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../model/social_user_model.dart';
import '../model/story_model.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final String currentUserId;
  final VoidCallback? onAddStory;

  const StoryViewerPage({
    super.key,
    required this.stories,
    required this.currentUserId,
    this.initialIndex = 0,
    this.onAddStory,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late int _current;
  late AnimationController _progressController;
  final _repo = SocialRepository();

  List<({SocialUserModel viewer, bool liked})> _viewers = [];
  bool _loadingViewers = false;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _togglingLike = false;

  StoryModel get _story => widget.stories[_current];
  bool get _isOwner => _story.userId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      })
      ..forward();
    _story.isSeen = true;
    _loadInteractionData();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadInteractionData() async {
    if (_isOwner) {
      setState(() => _loadingViewers = true);
      final viewers = await _repo.getStoryViewers(_story.id);
      if (mounted) setState(() { _viewers = viewers; _loadingViewers = false; });
    } else {
      await _repo.markStoryViewed(_story.id, widget.currentUserId);
      final info =
          await _repo.getStoryLikeInfo(_story.id, widget.currentUserId);
      if (mounted) {
        setState(() {
          _likeCount = info.count;
          _isLiked = info.isLiked;
        });
      }
    }
  }

  void _next() {
    if (_current < widget.stories.length - 1) {
      setState(() {
        _current++;
        _viewers = [];
        _isLiked = false;
        _likeCount = 0;
      });
      _story.isSeen = true;
      _progressController.forward(from: 0);
      _loadInteractionData();
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() {
        _current--;
        _viewers = [];
        _isLiked = false;
        _likeCount = 0;
      });
      _progressController.forward(from: 0);
      _loadInteractionData();
    }
  }

  Future<void> _toggleLike() async {
    if (_togglingLike) return;
    final wasLiked = _isLiked;
    setState(() {
      _togglingLike = true;
      _isLiked = !wasLiked;
      _likeCount = (_likeCount + (wasLiked ? -1 : 1)).clamp(0, 999999);
    });
    try {
      if (!wasLiked) {
        await _repo.likeStory(_story.id, widget.currentUserId);
      } else {
        await _repo.unlikeStory(_story.id, widget.currentUserId);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount = (_likeCount + (wasLiked ? 1 : -1)).clamp(0, 999999);
        });
      }
    } finally {
      if (mounted) setState(() => _togglingLike = false);
    }
  }

  Future<void> _showViewers() async {
    _progressController.stop();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ViewersSheet(
        viewers: _viewers,
        isLoading: _loadingViewers,
      ),
    );
    if (mounted) _progressController.forward();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (d) => d.localPosition.dx < sw / 2 ? _prev() : _next(),
        child: Stack(
          children: [
            // Full-screen story image
            Image.network(
              _story.imageUrl,
              width: sw,
              height: sh,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Colors.black87,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.white54, size: 60),
                ),
              ),
            ),
            // Top gradient
            Container(
              height: sh * 0.35,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: sh * 0.20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Top UI — absorbs its own taps so they don't trigger prev/next
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (_) {},
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bars
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: List.generate(
                          widget.stories.length,
                          (i) => Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: i < _current
                                    ? 1.0
                                    : i == _current
                                        ? _progressController.value
                                        : 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                      child: Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: _story.author.imageUrl != null
                                  ? Image.network(
                                      _story.author.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _avatarFallback(),
                                    )
                                  : _avatarFallback(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _story.author.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _timeAgo(_story.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_isOwner)
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.white, size: 22),
                              tooltip: 'Add story',
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onAddStory?.call();
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom UI — absorbs its own taps
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) {},
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child:
                        _isOwner ? _ownerBar(context) : _viewerBar(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ownerBar(BuildContext context) {
    return GestureDetector(
      onTap: _showViewers,
      child: Row(
        children: [
          const Icon(Icons.remove_red_eye_outlined,
              color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            _loadingViewers
                ? 'Loading...'
                : '${_viewers.length} viewer${_viewers.length == 1 ? '' : 's'}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_up_rounded,
              color: Colors.white70, size: 18),
        ],
      ),
    );
  }

  Widget _viewerBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_likeCount > 0) ...[
          Text(
            '$_likeCount',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15),
          ),
          const SizedBox(width: 6),
        ],
        GestureDetector(
          onTap: _toggleLike,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(_isLiked),
              color: _isLiked ? Colors.red : Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() => Container(
        color: context.iconBg,
        child: Icon(Icons.person_rounded, color: context.textMuted, size: 20),
      );
}

class _ViewersSheet extends StatelessWidget {
  final List<({SocialUserModel viewer, bool liked})> viewers;
  final bool isLoading;

  const _ViewersSheet({required this.viewers, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.remove_red_eye_outlined,
                    size: 20, color: context.textPrimary),
                const SizedBox(width: 8),
                Text(
                  '${viewers.length} viewer${viewers.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.border),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (viewers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No viewers yet',
                style: TextStyle(color: context.textMuted, fontSize: 14),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: viewers.length,
                itemBuilder: (context, i) {
                  final (:viewer, :liked) = viewers[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.iconBg,
                      backgroundImage: viewer.imageUrl != null
                          ? NetworkImage(viewer.imageUrl!)
                          : null,
                      child: viewer.imageUrl == null
                          ? Icon(Icons.person_rounded,
                              color: context.textMuted, size: 20)
                          : null,
                    ),
                    title: Text(viewer.username,
                        style: TextStyle(color: context.textPrimary)),
                    trailing: liked
                        ? const Icon(Icons.favorite_rounded,
                            color: Colors.red, size: 18)
                        : null,
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
