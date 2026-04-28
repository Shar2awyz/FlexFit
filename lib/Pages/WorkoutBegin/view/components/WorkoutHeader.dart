import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutHeader extends StatelessWidget {
  final String duration;
  final String volume;
  final int sets;

  const WorkoutHeader({
    super.key,
    required this.duration,
    required this.volume,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item("Duration", duration),
          _item("Volume", volume),
          _item("Sets", sets.toString()),
        ],
      ),
    );
  }

  Widget _item(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}