import 'dart:math' show min;
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
    final ref = min(sw, 480.0);

    // Define all spacing and sizing relative to the screen width reference 'ref' rather than LayoutBuilder constraints.
    // This gives a consistent visual look regardless of grid columns or parent constraints, and prevents vertical overflows.
    final padding = (ref * 0.035).clamp(8.0, 16.0);
    final borderRadius = (ref * 0.04).clamp(10.0, 18.0);

    final iconContainerPadding = (ref * 0.02).clamp(4.0, 10.0);
    final iconBorderRadius = (ref * 0.025).clamp(6.0, 12.0);
    final iconSize = (ref * 0.06).clamp(18.0, 26.0);

    final space1 = (ref * 0.02).clamp(4.0, 10.0);
    final valueFontSize = (ref * 0.05).clamp(14.0, 22.0);

    final space2 = (ref * 0.008).clamp(2.0, 4.0);
    final titleFontSize = (ref * 0.032).clamp(11.0, 14.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerPadding),
            decoration: BoxDecoration(
              color: context.accentBg,
              borderRadius: BorderRadius.circular(iconBorderRadius),
            ),
            child: Icon(
              icon,
              color: context.accentLight,
              size: iconSize,
            ),
          ),
          SizedBox(height: space1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: space2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: titleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
