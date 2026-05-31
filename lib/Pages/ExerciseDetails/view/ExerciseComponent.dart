import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

class ExerciseComponent extends StatelessWidget {
  final String name;
  final String description;
  final String equipment;

  const ExerciseComponent({
    super.key,
    required this.name,
    required this.description,
    required this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(sw * 0.045),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: sw * 0.042,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sw * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sw * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: context.accentLight,
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.02),
                Row(
                  children: [
                    Icon(Icons.build_rounded,
                        color: context.textMuted, size: sw * 0.036),
                    SizedBox(width: sw * 0.015),
                    Expanded(
                      child: Text(
                        equipment,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: sw * 0.032,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.03),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.03),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.redAccent, size: sw * 0.06),
              ),
              SizedBox(height: sw * 0.01),
              Text(
                'Watch',
                style:
                    TextStyle(color: context.textMuted, fontSize: sw * 0.026),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
