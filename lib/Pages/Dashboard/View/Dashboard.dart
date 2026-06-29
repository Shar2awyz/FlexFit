import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/Pages/Components/DashboardPageComponents/DashboardSummary.dart';
import 'package:flex_fit/theme/app_colors.dart';

import 'package:lottie/lottie.dart';
import '../Repository.dart';
import '../ViewModel/DashboardViewModel.dart';
import '../../Notifications/ViewModel/NotificationsViewModel.dart';

class Dashboard extends StatelessWidget {
  final String userid;

  const Dashboard({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(DashboardRepository())..load(userid),
      child: _DashboardView(userid: userid),
    );
  }
}

class _DashboardView extends StatefulWidget {
  final String userid;

  const _DashboardView({required this.userid});

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
    // We watch NotificationsViewModel here to trigger badge updates if needed, though they also happen reactive.
    context.watch<NotificationsViewModel>();

    return Scaffold(
      backgroundColor: context.pageBg,
      body: Builder(
        builder: (ctx) {
          if (vm.isLoading && vm.data == null) {
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

          if (vm.error != null && vm.data == null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.data == null) {
            return const Center(child: Text("No Data"));
          }

          final data = vm.data!;

          return Dashboardsummary(
            username: data['username'] ?? "User",
            workouts: vm.workoutCount,
            streak: vm.streak,
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
