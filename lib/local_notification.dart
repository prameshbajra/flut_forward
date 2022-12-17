import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        new AndroidInitializationSettings('mipmap/ic_launcher');
    var iosInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iosInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin
          flutterLocalNotificationsPlugin}) async {
    AndroidNotificationDetails androidNotificationDetails =
        new AndroidNotificationDetails('channel_id', 'channel_name',
            playSound: true,
            importance: Importance.max,
            priority: Priority.high);
    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: IOSNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
  }
}
