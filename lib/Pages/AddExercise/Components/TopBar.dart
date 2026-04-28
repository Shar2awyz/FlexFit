import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const TopBar({
    super.key,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            "New Split",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFinish,
            child: const Text(
              "Finish",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}