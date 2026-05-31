import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_history_model.dart';
import 'package:untitled6/Pages/WorkoutDetail/view/workout_detail_page.dart';
import 'package:untitled6/theme/app_colors.dart';
import '../app_route.dart';

class WorkoutHistoryCard extends StatelessWidget {
  final WorkoutHistoryModel workout;

  const WorkoutHistoryCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    // Cap the sizing reference so cards stay readable on tablets/web.
    final ref = min(sw, 480.0);

    final iconBoxSize = (ref * 0.12).clamp(40.0, 60.0);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        appRoute((_) => WorkoutDetailPage(workout: workout)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: (ref * 0.03).clamp(8.0, 16.0)),
        padding: EdgeInsets.all((ref * 0.04).clamp(12.0, 20.0)),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius:
              BorderRadius.circular((ref * 0.04).clamp(10.0, 20.0)),
          border: Border.all(color: context.border, width: 1),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius:
                    BorderRadius.circular((ref * 0.03).clamp(8.0, 16.0)),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: context.accentLight,
                size: (ref * 0.055).clamp(18.0, 30.0),
              ),
            ),
            SizedBox(width: (ref * 0.035).clamp(8.0, 18.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: (ref * 0.038).clamp(13.0, 20.0),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: (ref * 0.01).clamp(2.0, 6.0)),
                  Text(
                    '${workout.exerciseCount} exercises · ${workout.totalSets} sets',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: (ref * 0.031).clamp(11.0, 16.0),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  workout.formattedDuration,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: (ref * 0.034).clamp(12.0, 18.0),
                  ),
                ),
                SizedBox(height: (ref * 0.008).clamp(2.0, 5.0)),
                Text(
                  workout.formattedDate,
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: (ref * 0.028).clamp(10.0, 14.0),
                  ),
                ),
              ],
            ),
            SizedBox(width: (ref * 0.02).clamp(4.0, 10.0)),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textMuted,
              size: (ref * 0.05).clamp(16.0, 26.0),
            ),
          ],
        ),
      ),
    );
  }
}
