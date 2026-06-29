import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';

import 'package:flex_fit/Pages/ExerciseDetails/view/ExerciseDetailsPage.dart';
import 'package:flex_fit/Pages/Exercises_Components/Exercises_Component.dart';
import 'Components/app_route.dart';

class Exercises extends StatelessWidget {
  final String userid;

  const Exercises({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

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
