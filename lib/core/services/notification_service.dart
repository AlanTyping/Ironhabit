import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String channelId = 'pomodoro_channel';
  static const String channelName = 'Pomodoro Timer';
  static const int notificationId = 888;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Manejar toque en la notificación si es necesario
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.low,
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
        
    // Solicitar permiso en Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showTimerNotification({
    required String title,
    required String content,
    bool isOngoing = true,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: isOngoing,
      onlyAlertOnce: true,
      showWhen: false,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: notificationId,
      title: title,
      body: content,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(id: notificationId);
  }
}
