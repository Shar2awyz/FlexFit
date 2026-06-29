import 'dart:async';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/Pages/WorkoutBegin/view/WorkoutBegin.dart';
import 'package:flex_fit/Pages/WorkoutBegin/viewmodel/cubit/WorkoutBeginCubit.dart';
import 'package:flex_fit/Pages/WorkoutBegin/viewmodel/cubit/WorkoutBeginState.dart';
import 'package:flex_fit/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showSocialBadge;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showSocialBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final ref = min(w, 480.0);

        return BlocBuilder<WorkoutBeginCubit, WorkoutBeginState>(
          builder: (context, state) {
            final cubit = context.read<WorkoutBeginCubit>();
            final inProgress = cubit.isWorkoutInProgress;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (inProgress) ...[
                  _ActiveWorkoutMiniPlayer(
                    cubit: cubit,
                    ref: ref,
                  ),
                  SizedBox(height: (ref * 0.02).clamp(4.0, 8.0)),
                ],
                Container(
                  margin: EdgeInsets.fromLTRB(
                    (ref * 0.04).clamp(8.0, 24.0),
                    0,
                    (ref * 0.04).clamp(8.0, 24.0),
                    (ref * 0.04).clamp(8.0, 24.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: (ref * 0.02).clamp(4.0, 12.0)),
                  decoration: BoxDecoration(
                    color: context.navBg,
                    borderRadius: BorderRadius.circular((ref * 0.06).clamp(16.0, 32.0)),
                    boxShadow: context.cardShadow,
                  ),
                  child: LayoutBuilder(
                    builder: (context, barConstraints) {
                      final barWidth = barConstraints.maxWidth;
                      const numItems = 5;
                      final itemWidth = barWidth / numItems;
                      
                      // Calculate bubble width and offset with responsive horizontal spacing
                      final pillWidth = itemWidth - 10.0;
                      final leftOffset = currentIndex * itemWidth + 5.0;

                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOutCubic,
                            left: leftOffset,
                            top: 0,
                            bottom: 0,
                            width: pillWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.accentBg,
                                borderRadius: BorderRadius.circular((ref * 0.04).clamp(12.0, 20.0)),
                                border: Border.all(
                                  color: context.accent.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _NavBarItem(
                                icon: Icons.grid_view_rounded,
                                label: 'Dashboard',
                                isSelected: currentIndex == 0,
                                onTap: () => onTap(0),
                                ref: ref,
                              ),
                              _NavBarItem(
                                icon: Icons.play_circle_outline_rounded,
                                label: 'Workout',
                                isSelected: currentIndex == 1,
                                onTap: () => onTap(1),
                                ref: ref,
                              ),
                              _NavBarItem(
                                icon: Icons.fitness_center_rounded,
                                label: 'Exercises',
                                isSelected: currentIndex == 2,
                                onTap: () => onTap(2),
                                ref: ref,
                              ),
                              _NavBarItem(
                                icon: Icons.people_alt_rounded,
                                label: 'Social',
                                isSelected: currentIndex == 3,
                                onTap: () => onTap(3),
                                ref: ref,
                                showBadge: showSocialBadge,
                              ),
                              _NavBarItem(
                                icon: Icons.person_rounded,
                                label: 'Profile',
                                isSelected: currentIndex == 4,
                                onTap: () => onTap(4),
                                ref: ref,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double ref;
  final bool showBadge;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.ref,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = context.accentLight;
    final inactiveColor = context.textMuted;
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: (ref * 0.01).clamp(2.0, 6.0)),
          child: AnimatedScale(
            scale: isSelected ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TweenAnimationBuilder<Color?>(
                      duration: const Duration(milliseconds: 300),
                      tween: ColorTween(end: color),
                      builder: (context, animatedColor, child) {
                        return Icon(
                          icon,
                          color: animatedColor,
                          size: (ref * 0.062).clamp(18.0, 32.0),
                        );
                      },
                    ),
                    if (showBadge)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.navBg,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: color,
                    fontSize: isSelected
                        ? (ref * 0.028).clamp(8.0, 14.0)
                        : (ref * 0.026).clamp(8.0, 13.0),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveWorkoutMiniPlayer extends StatefulWidget {
  final WorkoutBeginCubit cubit;
  final double ref;

  const _ActiveWorkoutMiniPlayer({
    required this.cubit,
    required this.ref,
  });

  @override
  State<_ActiveWorkoutMiniPlayer> createState() => _ActiveWorkoutMiniPlayerState();
}

class _ActiveWorkoutMiniPlayerState extends State<_ActiveWorkoutMiniPlayer> {
  Timer? _timer;
  String _elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ActiveWorkoutMiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cubit.startTime != widget.cubit.startTime) {
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _updateTime();
    });
  }

  void _updateTime() {
    final startTime = widget.cubit.startTime;
    if (startTime != null) {
      final diff = DateTime.now().difference(startTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      final seconds = diff.inSeconds.remainder(60);

      final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
      final minutesStr = minutes.toString().padLeft(2, '0');
      final secondsStr = seconds.toString().padLeft(2, '0');

      setState(() {
        _elapsedTime = '$hoursStr$minutesStr:$secondsStr';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;
    final cubit = widget.cubit;

    return GestureDetector(
      onTap: () {
        if (cubit.splitDayId != null && cubit.workoutName != null) {
          Navigator.push(
            context,
            appRoute((_) => WorkoutBegin(
              dayId: cubit.splitDayId!,
              dayName: cubit.workoutName!,
              resume: true,
            )),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: (ref * 0.04).clamp(12.0, 24.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (ref * 0.04).clamp(12.0, 16.0),
          vertical: (ref * 0.020).clamp(10.0, 14.0),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.accent,
              context.accentLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular((ref * 0.04).clamp(12.0, 20.0)),
          boxShadow: [
            BoxShadow(
              color: context.accent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _PulsingGymIcon(ref: ref),
            SizedBox(width: (ref * 0.03).clamp(8.0, 12.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cubit.workoutName ?? 'Workout in Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: (ref * 0.036).clamp(13.0, 16.0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white70,
                        size: (ref * 0.032).clamp(11.0, 14.0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _elapsedTime,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: (ref * 0.032).clamp(11.0, 14.0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white,
                size: (ref * 0.05).clamp(18.0, 24.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingGymIcon extends StatefulWidget {
  final double ref;
  const _PulsingGymIcon({required this.ref});

  @override
  State<_PulsingGymIcon> createState() => _PulsingGymIconState();
}

class _PulsingGymIconState extends State<_PulsingGymIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.fitness_center_rounded,
          color: Colors.white,
          size: (widget.ref * 0.045).clamp(16.0, 22.0),
        ),
      ),
    );
  }
}

