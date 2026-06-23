import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Workmanager executing task: $task");
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userid');
      if (userId == null) {
        print("Workmanager: No user ID found, skipping check.");
        return true;
      }

      // Initialize Supabase if not already done in this isolate
      try {
        await dotenv.load(fileName: ".env");
        await Supabase.initialize(
          url: dotenv.env['SUPABASE_URL'] ?? '',
          anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
        );
      } catch (e) {
        // Already initialized or fails silently
        print("Supabase init error inside workmanager: $e");
      }

      final supabase = Supabase.instance.client;
      final lastCheckedStr = prefs.getString('last_notification_check');
      final DateTime since = lastCheckedStr != null
          ? DateTime.parse(lastCheckedStr)
          : DateTime.now().subtract(const Duration(hours: 24));

      print("Workmanager checking notifications since: $since");

      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .gt('created_at', since.toUtc().toIso8601String())
          .order('created_at', ascending: true);

      final List dataList = response as List;
      print("Workmanager found ${dataList.length} new unread notifications.");

      if (dataList.isNotEmpty) {
        final localNotifications = FlutterLocalNotificationsPlugin();
        // Initialize for this isolate
        const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
        const initializationSettingsDarwin = DarwinInitializationSettings();
        const initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
        await localNotifications.initialize(initializationSettings);

        DateTime latest = since;
        for (final json in dataList) {
          final id = json['id'].toString().hashCode;
          final title = json['title'] ?? 'New Notification';
          final message = json['message'] ?? '';
          final createdAt = DateTime.parse(json['created_at'] as String);

          if (createdAt.isAfter(latest)) {
            latest = createdAt;
          }

          const androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'flex_fit_channel',
            'Flex Fit Notifications',
            channelDescription: 'This channel is used for Flex Fit notifications.',
            importance: Importance.max,
            priority: Priority.high,
          );
          const platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: DarwinNotificationDetails(),
          );

          await localNotifications.show(
            id,
            title,
            message,
            platformChannelSpecifics,
          );
        }

        await prefs.setString('last_notification_check', latest.toIso8601String());
      } else {
        await prefs.setString('last_notification_check', DateTime.now().toUtc().toIso8601String());
      }
    } catch (e) {
      print("Error in Workmanager background task: $e");
    }
    return true;
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initializationSettingsDarwin = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification tapped: ${details.payload}");
      },
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'flex_fit_channel',
          'Flex Fit Notifications',
          description: 'This channel is used for Flex Fit notifications.',
          importance: Importance.max,
        ));

    // Request permissions for Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'flex_fit_channel',
      'Flex Fit Notifications',
      channelDescription: 'This channel is used for Flex Fit notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> registerBackgroundSync() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
    
    // Set up periodic task running every 15 minutes (minimum allowed by OS)
    await Workmanager().registerPeriodicTask(
      "flex_fit_background_sync",
      "flex_fit_background_sync_task",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    
    // Store current time as start baseline so we don't spam old notifications
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('last_notification_check') == null) {
      await prefs.setString(
        'last_notification_check',
        DateTime.now().toUtc().toIso8601String(),
      );
    }
  }

  static Future<void> cancelBackgroundSync() async {
    await Workmanager().cancelAll();
  }
}
