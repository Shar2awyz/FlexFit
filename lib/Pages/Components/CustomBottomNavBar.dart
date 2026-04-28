import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.04),
      padding: EdgeInsets.symmetric(vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: context.navBg,
        borderRadius: BorderRadius.circular(sw * 0.06),
        boxShadow: context.cardShadow,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: context.accentLight,
        unselectedItemColor: context.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: sw * 0.028,
        unselectedFontSize: sw * 0.026,
        iconSize: sw * 0.062,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
