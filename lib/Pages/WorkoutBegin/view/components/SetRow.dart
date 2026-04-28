import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetRow extends StatelessWidget {
  final String hint;
  final TextEditingController weightController;
  final TextEditingController repsController;

  const SetRow({
    super.key,
    required this.hint,
    required this.weightController,
    required this.repsController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Reps",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
        ),
        const Icon(Icons.check, color: Colors.green),
      ],
    );
  }
}