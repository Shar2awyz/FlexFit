import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get mainType {
    final parts = type.split(':');
    return parts[0];
  }

  String? get friendshipId {
    final parts = type.split(':');
    return parts.length > 1 ? parts[1] : null;
  }

  IconData get icon {
    final mType = mainType;
    if (mType.startsWith('streak_')) {
      return Icons.local_fire_department_rounded;
    }
    return switch (mType) {
      'workout_reminder' => Icons.fitness_center_rounded,
      'friend_request_received' => Icons.person_add_rounded,
      'friend_request_accepted' => Icons.handshake_rounded,
      'friend_joined' => Icons.celebration_rounded,
      'friend_workout' => Icons.directions_run_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color getIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mType = mainType;
    if (mType.startsWith('streak_')) {
      return isDark ? const Color(0xFFFF8C00) : const Color(0xFFFF4500); // orange-red
    }
    return switch (mType) {
      'workout_reminder' => isDark ? const Color(0xFFFFC107) : const Color(0xFFE65100), // amber/orange
      'friend_request_received' => const Color(0xFF2196F3), // blue
      'friend_request_accepted' => const Color(0xFF4CAF50), // green
      'friend_joined' => const Color(0xFF9C27B0), // purple
      'friend_workout' => const Color(0xFF00BCD4), // teal
      _ => isDark ? Colors.white70 : Colors.black54,
    };
  }
}
