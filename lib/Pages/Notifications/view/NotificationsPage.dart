import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ViewModel/NotificationsViewModel.dart';
import '../model/notification_model.dart';
import 'package:flex_fit/theme/app_colors.dart';
import 'package:flex_fit/Pages/Social/SocialRepository.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatAbsoluteTime(DateTime dateTime) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = monthNames[dateTime.month - 1];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dateTime.day}, ${dateTime.year} at $hour:$minute $amPm';
  }

  void _showSimulationBottomSheet(BuildContext context) {
    final vm = context.read<NotificationsViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final presets = [
          {
            'type': 'workout_reminder',
            'title': 'Workout Reminder',
            'message': 'You haven\'t completed today\'s workout. Let\'s get moving!',
          },
          {
            'type': 'streak_3',
            'title': '3-Day Streak!',
            'message': 'Keep the fire burning! 3 days in a row.',
          },
          {
            'type': 'streak_7',
            'title': '7-Day Streak!',
            'message': 'Weekly milestone reached! 7 days of dedication.',
          },
          {
            'type': 'streak_30',
            'title': '30-Day Streak!',
            'message': 'Unstoppable consistency! 30 days completed.',
          },
          {
            'type': 'friend_request_received:00000000-0000-0000-0000-000000000000',
            'title': 'Friend Request',
            'message': 'John Doe sent you a friend request.',
          },
          {
            'type': 'friend_request_accepted',
            'title': 'Friend Request Accepted',
            'message': 'Sarah Connor accepted your friend request.',
          },
          {
            'type': 'friend_joined',
            'title': 'Friend Joined',
            'message': 'Arnold Schwarzenegger just joined the app!',
          },
          {
            'type': 'friend_workout',
            'title': 'Friend Activity',
            'message': 'David Goggins completed "Morning Run & Lift" (120 mins).',
          },
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Simulate Notification Types',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a preset to insert it into Supabase in real time.',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: presets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final item = presets[idx];
                    final notif = NotificationModel(
                      id: '',
                      userId: '',
                      title: item['title']!,
                      message: item['message']!,
                      type: item['type']!,
                      isRead: false,
                      createdAt: DateTime.now(),
                    );
                    final color = notif.getIconColor(context);

                    return InkWell(
                      onTap: () async {
                        String name = 'Someone';
                        final type = item['type']!;
                        if (type.startsWith('friend_') || type.startsWith('workout_')) {
                          try {
                            final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                            final users = await Supabase.instance.client
                                .from('Users')
                                .select('username')
                                .neq('id', currentUserId ?? '')
                                .limit(5);
                            if (users.isNotEmpty) {
                              name = users[0]['username'] ?? 'Someone';
                            }
                          } catch (_) {}
                        }

                        String finalMessage = item['message']!;
                        if (type.startsWith('friend_request_received')) {
                          finalMessage = '$name sent you a friend request.';
                        } else if (type.startsWith('friend_request_accepted')) {
                          finalMessage = '$name accepted your friend request.';
                        } else if (type.startsWith('friend_joined')) {
                          finalMessage = '$name just joined the app!';
                        } else if (type.startsWith('friend_workout')) {
                          finalMessage = '$name completed "Morning Run & Lift" (120 mins).';
                        }

                        vm.generateDemoNotification(
                          type,
                          item['title']!,
                          finalMessage,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Triggered simulated "${item['title']}" notification!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.innerCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.border),
                        ),
                        child: Row(
                          children: [
                            Icon(notif.icon, color: color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    item['message']!,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: context.textMuted,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    final notifications = vm.notifications;
    final unreadCount = vm.unreadCount;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Simulate Notification',
            icon: const Icon(Icons.science_outlined),
            onPressed: () => _showSimulationBottomSheet(context),
          ),
          if (notifications.isNotEmpty) ...[
            if (unreadCount > 0)
              IconButton(
                tooltip: 'Mark all as read',
                icon: const Icon(Icons.mark_chat_read_outlined),
                onPressed: () {
                  vm.markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    vm.error!,
                    style: TextStyle(color: context.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        vm.loadNotifications(userId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        shape: BoxShape.circle,
                        boxShadow: context.cardShadow,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: context.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Notifications Yet',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay tuned! You\'ll see reminders, streak milestones, and friend requests here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showSimulationBottomSheet(context),
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Try Simulator'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                await vm.loadNotifications(userId, showSilent: true);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    vm.deleteNotification(notif.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            // Undo deletion by re-inserting
                            vm.generateDemoNotification(notif.type, notif.title, notif.message);
                          },
                        ),
                      ),
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  child: _NotificationListTile(
                    notification: notif,
                    relativeTime: _formatRelativeTime(notif.createdAt),
                    absoluteTime: _formatAbsoluteTime(notif.createdAt),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  final NotificationModel notification;
  final String relativeTime;
  final String absoluteTime;

  const _NotificationListTile({
    required this.notification,
    required this.relativeTime,
    required this.absoluteTime,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final typeColor = notification.getIconColor(context);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? context.accent.withValues(alpha: 0.4) : context.border,
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isUnread) {
              context.read<NotificationsViewModel>().markAsRead(notification.id);
            } else {
              // Show absolute time info / metadata in dialog or simple feedback
              _showDetailDialog(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.icon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Text columns
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            relativeTime,
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: isUnread ? context.textPrimary : context.textSecondary,
                          fontSize: 13.5,
                          height: 1.3,
                        ),
                      ),
                      if (notification.mainType == 'friend_request_received' &&
                          notification.friendshipId != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(80, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final friendshipId = notification.friendshipId!;
                                try {
                                  await SocialRepository().acceptFriendRequest(friendshipId);
                                  await context.read<NotificationsViewModel>().deleteNotification(notification.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Friend request accepted!')),
                                  );
                                } catch (e) {
                                  // For simulated/deleted request rows, let's still delete the notification card in the UI
                                  await context.read<NotificationsViewModel>().deleteNotification(notification.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Friend request processed ($e)')),
                                  );
                                }
                              },
                              child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.textSecondary,
                                side: BorderSide(color: context.border),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(80, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final friendshipId = notification.friendshipId!;
                                try {
                                  await SocialRepository().rejectFriendRequest(friendshipId);
                                  await context.read<NotificationsViewModel>().deleteNotification(notification.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Friend request declined.')),
                                  );
                                } catch (e) {
                                  // For simulated/deleted request rows, let's still delete the notification card in the UI
                                  await context.read<NotificationsViewModel>().deleteNotification(notification.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Friend request declined ($e)')),
                                  );
                                }
                              },
                              child: const Text('Decline', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        absoluteTime,
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicator dots / Actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: context.accent,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      IconButton(
                        tooltip: 'Delete',
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: context.textMuted,
                        ),
                        onPressed: () {
                          context.read<NotificationsViewModel>().deleteNotification(notification.id);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: const TextStyle(fontSize: 15, height: 1.3),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    absoluteTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
