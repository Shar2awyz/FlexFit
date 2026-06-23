import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/Pages/Components/DashboardPageComponents/DashboardSummary.dart';
import 'package:flex_fit/Pages/Exercises.dart';
import 'package:flex_fit/Pages/Profile/view/ProfilePage.dart';
import 'package:flex_fit/Pages/Social/SocialNotificationService.dart';
import 'package:flex_fit/Pages/Social/view/SocialFeedPage.dart';
import 'package:flex_fit/Pages/StartWorkout/view/StartWorkoutPage.dart';
import 'package:flex_fit/theme/app_colors.dart';

import '../../Components/CustomBottomNavBar.dart';
import '../../Components/app_route.dart';
import '../../Login/View/LoginScreen.dart';
import 'package:lottie/lottie.dart';
import '../Repository.dart';
import '../ViewModel/DashboardViewModel.dart';
import '../../Notifications/ViewModel/NotificationsViewModel.dart';

class Dashboard extends StatelessWidget {
  final String userid;

  const Dashboard({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(DashboardRepository())..load(userid),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SocialNotificationService(userId: userid)..initialize(),
        ),
      ],
      child: _DashboardView(userid: userid),
    );
  }
}

class _DashboardView extends StatefulWidget {
  final String userid;

  const _DashboardView({super.key, required this.userid});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationsViewModel>().initialize(widget.userid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final notifService = context.watch<SocialNotificationService>();
    // We watch NotificationsViewModel here to trigger badge updates if needed, though they also happen reactive.
    context.watch<NotificationsViewModel>();

    return Scaffold(
      backgroundColor: context.pageBg,

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        showSocialBadge: notifService.hasBadge,
        onTap: (i) {
          if (i == 0) return;
          if (i == 4) {
            notifService.markAsSeen();
            Navigator.push(
              context,
              appRoute((_) => SocialFeedPage(
                currentUserId: widget.userid,
                onNavTap: (tab) {
                  Navigator.pop(context);
                  if (tab == 1) {
                    Navigator.push(context, appRoute((_) => StartWorkout(userid: widget.userid)));
                  } else if (tab == 2) {
                    Navigator.push(context, appRoute((_) => Exercises(userid: widget.userid)));
                  } else if (tab == 3) {
                    Navigator.push(context, appRoute((_) => Profile(userid: widget.userid)));
                  }
                },
              )),
            );
          } else if (i == 3) {
            Navigator.push(
              context,
              appRoute((_) => Profile(userid: widget.userid)),
            );
          } else if (i == 2) {
            Navigator.push(
              context,
              appRoute((_) => Exercises(userid: widget.userid)),
            );
          } else if (i == 1) {
            Navigator.push(
              context,
              appRoute((_) => StartWorkout(userid: widget.userid)),
            );
          }
        },
      ),

      body: Builder(
        builder: (ctx) {
          if (vm.isLoading) {
            return Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  'animation/Icon gym for Sporttler.json',
                  fit: BoxFit.contain,
                ),
              ),
            );
          }

          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.data == null) {
            return const Center(child: Text("No Data"));
          }

          final data = vm.data!;
          final mq = MediaQuery.of(ctx);
          final sw = mq.size.width;
          final topPad = mq.padding.top;

          return Dashboardsummary(
            username: data['username'] ?? "User",
            workouts: vm.workoutCount,
            calories: 1200,
            time: vm.totalDurationMinutes,
            progress: vm.progress,
            photo: data['image_url'],
            history: vm.workoutHistory,
          );
        },
      ),
    );
  }
}
