import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Repository/NotificationsRepository.dart';
import '../model/notification_model.dart';
import 'package:untitled6/services/notification_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationsRepository repository;

  NotificationsViewModel(this.repository);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  RealtimeChannel? _channel;
  String? _currentUserId;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get latestThree => _notifications.take(3).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize(String userId) async {
    // Prevent double initialization if it's the same user
    if (_currentUserId == userId) return;
    _currentUserId = userId;

    await loadNotifications(userId);
    _subscribeToRealtime(userId);
  }

  Future<void> loadNotifications(String userId, {bool showSilent = false}) async {
    if (!showSilent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final list = await repository.getNotifications(userId);
      _notifications = list;
    } catch (e) {
      _error = "Failed to load notifications";
      print("NotificationsViewModel load error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToRealtime(String userId) {
    _channel?.unsubscribe();
    
    final supabaseClient = Supabase.instance.client;
    
    _channel = supabaseClient
        .channel('realtime_user_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print("Realtime update received: ${payload.eventType}");
            if (payload.eventType == PostgresChangeEvent.insert && payload.newRecord.isNotEmpty) {
              final newRecord = payload.newRecord;
              final id = newRecord['id']?.toString().hashCode ?? DateTime.now().millisecondsSinceEpoch;
              final title = newRecord['title'] as String? ?? 'New Notification';
              final message = newRecord['message'] as String? ?? '';
              NotificationService.showNotification(
                id: id,
                title: title,
                body: message,
              );
            }
            // Silently reload to keep data in sync without flashing loaders
            loadNotifications(userId, showSilent: true);
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Optimistic update
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          userId: old.userId,
          title: old.title,
          message: old.message,
          type: old.type,
          isRead: true,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }

      await repository.markAsRead(notificationId);
    } catch (e) {
      print("Failed to mark as read: $e");
      if (_currentUserId != null) {
        loadNotifications(_currentUserId!, showSilent: true);
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    try {
      // Optimistic update
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      notifyListeners();

      await repository.markAllAsRead(_currentUserId!);
    } catch (e) {
      print("Failed to mark all as read: $e");
      if (_currentUserId != null) {
        loadNotifications(_currentUserId!, showSilent: true);
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // Optimistic update
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      await repository.deleteNotification(notificationId);
    } catch (e) {
      print("Failed to delete notification: $e");
      if (_currentUserId != null) {
        loadNotifications(_currentUserId!, showSilent: true);
      }
    }
  }

  // Simulated notification generation for testing/demo
  Future<void> generateDemoNotification(String type, String title, String message) async {
    if (_currentUserId == null) return;
    try {
      await repository.addNotification(
        userId: _currentUserId!,
        title: title,
        message: message,
        type: type,
      );
    } catch (e) {
      print("Failed to generate demo notification: $e");
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
