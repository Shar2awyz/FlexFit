import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled6/Pages/Components/DashboardPageComponents/DashboardSummary.dart';
import 'package:untitled6/Pages/Exercises.dart';
import 'package:untitled6/Pages/Profile.dart';
import 'package:untitled6/Pages/Start_Workout.dart';
import 'package:untitled6/services/sharedpref.dart';

import '../../Components/CustomBottomNavBar.dart';
import '../../Components/app_route.dart';
import '../../Login/View/LoginScreen.dart';
import '../Repository.dart';
import '../ViewModel/DashboardViewModel.dart';


// 🔹 IMPORT YOUR VM + REPO


class Dashboard extends StatelessWidget {
  final String userid;

  const Dashboard({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      DashboardViewModel(DashboardRepository())..load(userid),
      child: _DashboardView(userid: userid),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final String userid;

  const _DashboardView({required this.userid});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),

      /// ✅ Bottom Nav (same behavior, cleaner state)
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: vm.index,
        onTap: (i) {
          vm.changeIndex(i);

          if (i == 3) {
            Navigator.push(
              context,
              appRoute( (_) => Profile(userid: userid),
              ),
            );
          } else if (i == 2) {
            Navigator.push(
              context,
              appRoute( (_) => Exercises(userid: userid),
              ),
            );
          } else if (i == 1) {
            Navigator.push(
              context,
              appRoute( (_) => StartWorkout(userid: userid),
              ),
            );
          }
        },
      ),

      /// ✅ Body (replaces FutureBuilder)
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.data == null) {
            return const Center(child: Text("No Data"));
          }

          final data = vm.data!;

          return Stack(
            children: [
              /// ✅ Main UI (unchanged)
              Dashboardsummary(
                username: data['username'] ?? "User",
                workouts: vm.workoutCount,
                calories: 1200,
                time: vm.totalDurationMinutes,
                progress: 75,
                photo: data['image_url'],
                history: vm.workoutHistory,
              ),

              /// ✅ Logout Button (cleaned)
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  onPressed: () async {
                    await vm.logout();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      appRoute( (_) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}