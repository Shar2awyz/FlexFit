import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';

import 'package:flex_fit/Pages/ExerciseDetails/view/ExerciseDetailsPage.dart';
import 'package:flex_fit/Pages/Exercises_Components/Exercises_Component.dart';
import 'package:flex_fit/Pages/StartWorkout/view/StartWorkoutPage.dart';
import 'package:flex_fit/Pages/Social/view/SocialFeedPage.dart';

import 'Components/CustomBottomNavBar.dart';
import 'Components/app_route.dart';
import 'Dashboard/View/Dashboard.dart';
import 'Profile/view/ProfilePage.dart';

class Exercises extends StatelessWidget {
  final String userid;

  const Exercises({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    const int index = 2;

    const muscles = [
      {'title': 'Chest', 'image': 'images/muscle_icon_06.png'},
      {'title': 'Back', 'image': 'images/muscle_icon_02.png'},
      {'title': 'Arms', 'image': 'images/muscle_icon_03.png'},
      {'title': 'Legs', 'image': 'images/muscle_icon_04.png'},
      {'title': 'Shoulders', 'image': 'images/delts_front.png'},
      {'title': 'Core', 'image': 'images/muscle_icon_13.png'},
    ];

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: sw * 0.22,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercises',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: sw * 0.065,
              ),
            ),
            Text(
              'Select a muscle group',
              style: TextStyle(
                color: context.textMuted,
                fontSize: sw * 0.032,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: index,
        onTap: (i) {
          if (i == index) return;
          if (i == 0) {
            Navigator.pushReplacement(
                context, appRoute((_) => Dashboard(userid: userid)));
          } else if (i == 1) {
            Navigator.pushReplacement(
                context, appRoute((_) => StartWorkout(userid: userid)));
          } else if (i == 3) {
            Navigator.pushReplacement(
                context, appRoute((_) => Profile(userid: userid)));
          } else if (i == 4) {
            Navigator.push(
              context,
              appRoute((_) => SocialFeedPage(
                currentUserId: userid,
                onNavTap: (tab) {
                  Navigator.pop(context);
                  if (tab == 0) {
                    Navigator.pushReplacement(context, appRoute((_) => Dashboard(userid: userid)));
                  } else if (tab == 1) {
                    Navigator.pushReplacement(context, appRoute((_) => StartWorkout(userid: userid)));
                  } else if (tab == 3) {
                    Navigator.pushReplacement(context, appRoute((_) => Profile(userid: userid)));
                  }
                },
              )),
            );
          }
        },
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: sw * 0.04,
          crossAxisSpacing: sw * 0.04,
          crossAxisCount: 2,
          childAspectRatio: 1.05,
        ),
        padding: EdgeInsets.all(sw * 0.05),
        itemCount: muscles.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              appRoute((context) => ExerciseDetails(
                    userid: userid,
                    exerciseId: muscles[i]['title']!,
                  )),
            ),
            child: Exercise_Component(
              title: muscles[i]['title']!,
              imagePath: muscles[i]['image']!,
            ),
          );
        },
      ),
    );
  }
}
