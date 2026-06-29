import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/theme/app_colors.dart';
import 'package:flex_fit/Pages/Components/CustomBottomNavBar.dart';
import 'package:flex_fit/Pages/Dashboard/View/Dashboard.dart';
import 'package:flex_fit/Pages/StartWorkout/view/StartWorkoutPage.dart';
import 'package:flex_fit/Pages/Exercises.dart';
import 'package:flex_fit/Pages/Profile/view/ProfilePage.dart';
import 'package:flex_fit/Pages/Social/view/SocialFeedPage.dart';
import 'package:flex_fit/Pages/Social/SocialNotificationService.dart';

class RootNavigationShell extends StatelessWidget {
  final String userid;
  final int initialIndex;

  const RootNavigationShell({
    super.key,
    required this.userid,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocialNotificationService(userId: userid)..initialize(),
      child: _RootNavigationShellView(userid: userid, initialIndex: initialIndex),
    );
  }
}

class _RootNavigationShellView extends StatefulWidget {
  final String userid;
  final int initialIndex;

  const _RootNavigationShellView({
    required this.userid,
    required this.initialIndex,
  });

  @override
  State<_RootNavigationShellView> createState() => _RootNavigationShellViewState();
}

class _RootNavigationShellViewState extends State<_RootNavigationShellView> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      Dashboard(userid: widget.userid),
      StartWorkout(userid: widget.userid),
      Exercises(userid: widget.userid),
      SocialFeedPage(currentUserId: widget.userid),
      Profile(userid: widget.userid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notifService = context.watch<SocialNotificationService>();

    return Scaffold(
      backgroundColor: context.pageBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        showSocialBadge: notifService.hasBadge,
        onTap: (index) {
          if (index == 3) {
            notifService.markAsSeen();
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
