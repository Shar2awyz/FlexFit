import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../model/story_model.dart';

class StoryCircle extends StatelessWidget {
  final StoryModel story;
  final bool? isSeen;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    required this.story,
    this.isSeen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);
    final size = (ref * 0.17).clamp(60.0, 76.0);
    final seen = isSeen ?? story.isSeen;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: seen
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: seen ? context.border : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.pageBg, width: 2),
              ),
              child: ClipOval(
                child: story.author.imageUrl != null
                    ? Image.network(
                        story.author.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(context),
                      )
                    : _placeholder(context),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: size,
            child: Text(
              story.author.username,
              style: TextStyle(
                fontSize: (ref * 0.025).clamp(9.0, 11.0),
                color: context.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.iconBg,
      child: Icon(Icons.person_rounded, color: context.textMuted, size: 28),
    );
  }
}
