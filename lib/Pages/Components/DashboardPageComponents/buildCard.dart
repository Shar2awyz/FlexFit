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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        
        // Define all spacing and sizing relative to the local card width
        final padding = (w * 0.08).clamp(8.0, 20.0);
        final borderRadius = (w * 0.09).clamp(8.0, 22.0);
        
        final iconContainerPadding = (w * 0.045).clamp(4.0, 12.0);
        final iconBorderRadius = (w * 0.05).clamp(4.0, 14.0);
        final iconSize = (w * 0.12).clamp(14.0, 30.0);
        
        final space1 = (w * 0.05).clamp(4.0, 14.0);
        final valueFontSize = (w * 0.11).clamp(12.0, 26.0);
        
        final space2 = (w * 0.015).clamp(2.0, 6.0);
        final titleFontSize = (w * 0.07).clamp(9.0, 15.0);

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
      },
    );
  }
}
