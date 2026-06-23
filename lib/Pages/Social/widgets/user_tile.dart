import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';

import '../model/social_user_model.dart';

class UserTile extends StatelessWidget {
  final SocialUserModel user;
  final Widget? trailing;
  final VoidCallback? onTap;

  const UserTile({super.key, required this.user, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);
    final avatarSize = (ref * 0.11).clamp(40.0, 52.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: (ref * 0.04).clamp(12.0, 20.0),
          vertical: (ref * 0.03).clamp(10.0, 14.0),
        ),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: user.imageUrl != null
                    ? Image.network(
                        user.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _avatar(context, avatarSize),
                      )
                    : _avatar(context, avatarSize),
              ),
            ),
            SizedBox(width: (ref * 0.03).clamp(10.0, 14.0)),
            Expanded(
              child: Text(
                user.username,
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: (ref * 0.038).clamp(14.0, 16.0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.iconBg,
      child: Icon(Icons.person_rounded, color: context.textMuted),
    );
  }
}
