import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification(String userId) async {
    // 1. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);

    // Note: FCM (Firebase Cloud Messaging) removed. 
    // To implement Push Notifications with Supabase, one typically uses OneSignal or 
    // integrates FCM via Supabase Edge Functions.
    // For now, only local notifications and in-app realtime updates are supported.
  }

  Future<void> _saveTokenToDatabase(String userId, String token) async {
    await _supabase.from('users').update({
      'fcmToken': token,
    }).eq('uid', userId);
  }

  Future<void> sendNotification(String userId, String title, String body) async {
    // Save to Supabase for in-app feed
    await _supabase.from('notifications').insert({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });
    
    // In a real production app, this is where you'd call your Edge Function to send Push.
  }

  Future<void> showLocalNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'farmigo_channel_id', // id
      'Farmigo Notifications', // title
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

