import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/theme/app_colors.dart';
import 'package:flex_fit/Pages/AddExercise/view/AddExercisePage.dart';
import 'package:flex_fit/Pages/Components/CustomBottomNavBar.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/Pages/Dashboard/View/Dashboard.dart';
import 'package:flex_fit/Pages/Exercises.dart';
import 'package:flex_fit/Pages/Profile/view/ProfilePage.dart';
import 'package:flex_fit/Pages/StartWorkout/view/StartWorkoutPage.dart';
import '../WorkoutSplitRepository.dart';
import '../viewmodel/WorkoutSplitViewModel.dart';

class WorkoutSplitPage extends StatelessWidget {
  final String userid;

  const WorkoutSplitPage({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutSplitViewModel(
        WorkoutSplitRepository(),
        userId: userid,
      ),
      child: _WorkoutSplitView(userid: userid),
    );
  }
}

class _WorkoutSplitView extends StatefulWidget {
  final String userid;
  const _WorkoutSplitView({required this.userid});

  @override
  State<_WorkoutSplitView> createState() => _WorkoutSplitViewState();
}

class _WorkoutSplitViewState extends State<_WorkoutSplitView> {
  final _nameController = TextEditingController(text: 'My Split');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, appRoute((_) => Dashboard(userid: widget.userid)));
        break;
      case 2:
        Navigator.pushReplacement(
            context, appRoute((_) => Exercises(userid: widget.userid)));
        break;
      case 3:
        Navigator.pushReplacement(
            context, appRoute((_) => Profile(userid: widget.userid)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutSplitViewModel>();
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimary),
        title: TextField(
          controller: _nameController,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: sw * 0.048,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Split Name',
            hintStyle: TextStyle(color: context.textMuted),
            border: InputBorder.none,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (i) => _onNavTap(context, i),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.04, sw * 0.03, sw * 0.04, sw * 0.02),
            child: GestureDetector(
              onTap: () async {
                final splitId =
                    await vm.ensureSplitCreated(_nameController.text);
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  appRoute((_) => AddExercise(splitId: splitId)),
                );
                vm.loadDays();
              },
              child: Container(
                height: sw * 0.13,
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(sw * 0.035),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: Colors.white, size: sw * 0.055),
                    SizedBox(width: sw * 0.025),
                    Text(
                      'Add New Split Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sw * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: context.accentLight))
                : vm.days.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center_rounded,
                                color: context.textMuted, size: sw * 0.16),
                            SizedBox(height: sw * 0.04),
                            Text(
                              vm.splitId == null
                                  ? 'Tap "Add New Split Day" to begin'
                                  : 'No days yet',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: sw * 0.038,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04, vertical: sw * 0.01),
                        itemCount: vm.days.length,
                        itemBuilder: (context, index) {
                          final day = vm.days[index];
                          return Dismissible(
                            key: ValueKey(day['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: sw * 0.05),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(sw * 0.04),
                              ),
                              child: Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: sw * 0.055),
                            ),
                            onDismissed: (_) =>
                                vm.deleteDay(day['id'] as String, index),
                            child: Container(
                              margin: EdgeInsets.only(bottom: sw * 0.025),
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.04,
                                  vertical: sw * 0.035),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius:
                                    BorderRadius.circular(sw * 0.04),
                                border:
                                    Border.all(color: context.border, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: sw * 0.12,
                                    height: sw * 0.12,
                                    decoration: BoxDecoration(
                                      color: context.accentBg,
                                      borderRadius:
                                          BorderRadius.circular(sw * 0.03),
                                    ),
                                    child: Icon(Icons.calendar_today_rounded,
                                        color: context.accentLight,
                                        size: sw * 0.05),
                                  ),
                                  SizedBox(width: sw * 0.03),
                                  Text(
                                    day['name'] as String,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: sw * 0.038,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (vm.splitId != null && vm.days.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.04, 0, sw * 0.04, sw * 0.02),
              child: SizedBox(
                width: double.infinity,
                height: sw * 0.13,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.035)),
                  ),
                  icon: Icon(Icons.check_rounded, size: sw * 0.055),
                  label: Text(
                    'Done — Go to Workouts',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    appRoute((_) => StartWorkout(userid: widget.userid)),
                    (route) => false,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
