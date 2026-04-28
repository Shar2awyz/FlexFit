import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

class buildCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const buildCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(sw * 0.045),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.022),
            decoration: BoxDecoration(
              color: context.accentBg,
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(
              icon,
              color: context.accentLight,
              size: sw * 0.055,
            ),
          ),
          SizedBox(height: sw * 0.025),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: sw * 0.052,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          SizedBox(height: sw * 0.008),
          Text(
            title,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: sw * 0.03,
            ),
          ),
        ],
      ),
    );
  }
}
