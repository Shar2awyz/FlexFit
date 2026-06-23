import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flex_fit/Pages/premadeworkout/Components/ExerciseTitle.dart';

class WorkoutDayCard extends StatelessWidget {
  final String day;
  final String title;
  final List<String> exercises;

  const WorkoutDayCard({
    super.key,
    required this.day,
    required this.title,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...exercises.map((e) => ExerciseTile(name: e)),
        ],
      ),
    );
  }
}