import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/notification_model.dart';

class NotificationsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final dataList = response as List;
      return dataList
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching notifications: $e");
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      print("Error marking notification as read: $e");
      rethrow;
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print("Error marking all notifications as read: $e");
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', id);
    } catch (e) {
      print("Error deleting notification: $e");
      rethrow;
    }
  }

  Future<NotificationModel> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'title': title,
            'message': message,
            'type': type,
            'is_read': false,
          })
          .select()
          .single();
      return NotificationModel.fromJson(response);
    } catch (e) {
      print("Error creating notification: $e");
      rethrow;
    }
  }
}
