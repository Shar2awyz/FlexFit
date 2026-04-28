import 'package:flutter/material.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_history_model.dart';
import 'package:untitled6/theme/app_colors.dart';

import 'buildCard.dart';
import 'workout_history_card.dart';

class Dashboardsummary extends StatelessWidget {
  final String username;
  final int workouts;
  final int calories;
  final int time;
  final int progress;
  final dynamic photo;
  final List<WorkoutHistoryModel> history;

  const Dashboardsummary({
    super.key,
    required this.username,
    required this.workouts,
    required this.calories,
    required this.time,
    required this.progress,
    required this.photo,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.pageBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sh * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good day,',
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: sw * 0.035,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Text(
                          username,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: sw * 0.065,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: sw * 0.065,
                    backgroundColor: context.cardBg,
                    backgroundImage: (photo != null &&
                            photo.toString().startsWith('http'))
                        ? NetworkImage(photo)
                        : null,
                    child: (photo == null ||
                            !photo.toString().startsWith('http'))
                        ? Icon(
                            Icons.person_rounded,
                            color: context.textMuted,
                            size: sw * 0.07,
                          )
                        : null,
                  ),
                ],
              ),

              SizedBox(height: sh * 0.03),

              // ── Stats grid ───────────────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: sw * 0.035,
                mainAxisSpacing: sw * 0.035,
                childAspectRatio: 1.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildCard(
                    title: 'Workouts',
                    value: workouts.toString(),
                    icon: Icons.fitness_center_rounded,
                  ),
                  buildCard(
                    title: 'Calories',
                    value: calories.toString(),
                    icon: Icons.local_fire_department_rounded,
                  ),
                  buildCard(
                    title: 'Total Time',
                    value: '$time min',
                    icon: Icons.timer_rounded,
                  ),
                  buildCard(
                    title: 'Progress',
                    value: '$progress%',
                    icon: Icons.trending_up_rounded,
                  ),
                ],
              ),

              SizedBox(height: sh * 0.035),

              // ── Recent workouts header ────────────────────────────────
              Row(
                children: [
                  Text(
                    'Recent Workouts',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: sw * 0.048,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    Text(
                      '${history.length} sessions',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: sw * 0.03,
                      ),
                    ),
                ],
              ),

              SizedBox(height: sw * 0.04),

              if (history.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: sh * 0.05,
                    horizontal: sw * 0.05,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(sw * 0.045),
                    border: Border.all(color: context.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        color: context.textMuted,
                        size: sw * 0.12,
                      ),
                      SizedBox(height: sw * 0.03),
                      Text(
                        'No workouts yet',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: sw * 0.01),
                      Text(
                        'Start your first session!',
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.032,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...history.map((w) => WorkoutHistoryCard(workout: w)),

              SizedBox(height: sw * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
