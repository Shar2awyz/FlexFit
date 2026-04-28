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

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        appRoute((_) => WorkoutDetailPage(workout: workout)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: sw * 0.03),
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(color: context.border, width: 1),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.12,
              height: sw * 0.12,
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(sw * 0.03),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: context.accentLight,
                size: sw * 0.055,
              ),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sw * 0.01),
                  Text(
                    '${workout.exerciseCount} exercises · ${workout.totalSets} sets',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: sw * 0.031,
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
                    fontSize: sw * 0.034,
                  ),
                ),
                SizedBox(height: sw * 0.008),
                Text(
                  workout.formattedDate,
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: sw * 0.028,
                  ),
                ),
              ],
            ),
            SizedBox(width: sw * 0.02),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textMuted,
              size: sw * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
