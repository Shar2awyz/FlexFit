import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';

class RoutineCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const RoutineCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: sw * 0.03),
      padding: EdgeInsets.all(sw * 0.038),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.028),
            decoration: BoxDecoration(
              color: context.accentBg,
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child:
                Icon(icon, color: context.accentLight, size: sw * 0.055),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: sw * 0.038,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sw * 0.006),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: sw * 0.03,
                  ),
                ),
              ],
            ),
          ),
          if (trailing case final w?) w,
        ],
      ),
    );
  }
}
