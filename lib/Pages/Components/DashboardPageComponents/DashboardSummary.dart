import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_history_model.dart';
import 'package:untitled6/theme/app_colors.dart';
import 'package:untitled6/Pages/Notifications/ViewModel/NotificationsViewModel.dart';
import 'package:untitled6/Pages/Notifications/view/NotificationsPage.dart';
import 'package:untitled6/Pages/Components/app_route.dart';

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

  // Grid columns: 2 on phones, 3 on small tablets, 4 on large tablets/web.
  int _gridColumns(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1.0) ?? 1.0;
    
    // Cap the sizing basis at 480 so fonts/spacing don't scale endlessly on
    // tablets or web — layout still fills the real screen width.
    final ref = min(sw, 480.0);
    final notificationsVm = context.watch<NotificationsViewModel>();
    final unreadCount = notificationsVm.unreadCount;

    final layoutWidth = min(sw, 800.0);
    final cols = _gridColumns(layoutWidth);
    final spacing = ref * 0.035;

    // Use consistent clamped padding to avoid layout breaking on wider screens
    final horizontalPadding = (sw * 0.05).clamp(8.0, 40.0);
    final gridWidth = layoutWidth - (horizontalPadding * 2);
    final cardWidth = (gridWidth - (cols - 1) * spacing) / cols;

    // Height scaled by text scale factor to accommodate larger fonts and prevent vertical overflow
    final cardHeight = (ref * 0.28).clamp(115.0, 140.0) * textScale;
    final ratio = cardWidth / cardHeight;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.pageBg,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Content never stretches beyond a comfortable reading width.
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: sh * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Good day,',
                                style: TextStyle(
                                  color: context.textMuted,
                                  fontSize: (ref * 0.035).clamp(12.0, 18.0),
                                ),
                              ),
                            ),
                            SizedBox(height: ref * 0.005),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                username,
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: (ref * 0.065).clamp(20.0, 36.0),
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: context.textPrimary,
                              size: (ref * 0.07).clamp(24.0, 36.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                appRoute((_) => const NotificationsPage()),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: ref * 0.02),
                      _Avatar(
                        photoUrl: photo?.toString(),
                        radius: (ref * 0.065).clamp(24.0, 40.0),
                        iconSize: (ref * 0.07).clamp(22.0, 40.0),
                      ),
                    ],
                  ),

                  SizedBox(height: sh * 0.03),

                  // ── Stats grid ──────────────────────────────────────
                  GridView.count(
                    crossAxisCount: cols,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: ratio,
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

                  // ── Recent workouts header ───────────────────────────
                  Row(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Workouts',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: (ref * 0.048).clamp(16.0, 26.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (history.isNotEmpty)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${history.length} sessions',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: (ref * 0.03).clamp(10.0, 16.0),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: ref * 0.04),

                  if (history.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: sh * 0.05,
                        horizontal: ref * 0.05,
                      ),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius:
                            BorderRadius.circular((ref * 0.045).clamp(12.0, 24.0)),
                        border: Border.all(color: context.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            color: context.textMuted,
                            size: (ref * 0.12).clamp(36.0, 64.0),
                          ),
                          SizedBox(height: ref * 0.03),
                          Text(
                            'No workouts yet',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: (ref * 0.04).clamp(13.0, 20.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ref * 0.01),
                          Text(
                            'Start your first session!',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: (ref * 0.032).clamp(11.0, 16.0),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...history.map((w) => WorkoutHistoryCard(workout: w)),

                  SizedBox(height: ref * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final double iconSize;

  const _Avatar({this.photoUrl, required this.radius, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: context.cardBg,
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, err, stack) => Icon(
                  Icons.person_rounded,
                  size: iconSize,
                  color: context.textMuted,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: iconSize,
                color: context.textMuted,
              ),
      ),
    );
  }
}
