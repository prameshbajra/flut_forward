import 'package:flutter/material.dart';
import 'package:flutter_codelab/home.dart';
import 'package:flutter_codelab/local_notification.dart';
import 'package:flutter_codelab/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

const taskName = 'task';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final Telephony telephony = Telephony.backgroundInstance;
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          LocalNotification.showNotification(
              title: 'Forwarder',
              body: 'Address: ${message.address} | Body: ${message.body}',
              flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
        },
        listenInBackground: true,
        onBackgroundMessage: backgrounMessageHandler);
    return Future.value(true);
  });
}

backgrounMessageHandler(SmsMessage message) async {
  LocalNotification.showNotification(
      title: 'Forwarder',
      body: 'Address: ${message.address} | Body: ${message.body}',
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager()
      .registerOneOffTask(Utility().generateRandomString(10), taskName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocalNotification.initialize(flutterLocalNotificationsPlugin);
    return MaterialApp(
      home: Home(),
    );
  }
}
