import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: context.border, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: context.textPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: context.textMuted),
          hintText: 'Search exercises...',
          hintStyle: TextStyle(color: context.textHint),
        ),
      ),
    );
  }
}
