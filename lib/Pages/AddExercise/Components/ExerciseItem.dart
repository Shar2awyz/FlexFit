import 'package:flutter/material.dart';
import 'package:untitled6/theme/app_colors.dart';

class ExerciseItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final String image;
  final bool isSelected;

  const ExerciseItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onAdd,
    required this.image,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Icon(
                      Icons.fitness_center,
                      size: 30,
                      color: context.accentLight,
                    ),
                  )
                : Icon(
                    Icons.fitness_center,
                    size: 30,
                    color: context.accentLight,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: isSelected ? context.accent : context.accentBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                color: isSelected ? Colors.white : context.accentLight,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
