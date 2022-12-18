import 'package:flutter/material.dart';
import 'package:flutter_codelab/home.dart';
import 'package:flutter_codelab/local_notification.dart';
import 'package:flutter_codelab/permissions.dart';
import 'package:flutter_codelab/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

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
  var url =
      Uri.https('run.mocky.io', '/v3/f3fcaeba-c5da-485a-bed4-4f71e123cbba');
  var response = await http.get(url);
  print('FOWARDER: ${response.body}');
  LocalNotification.showNotification(
      title: 'Forwarder Background.',
      body: 'Address: ${message.address} | Body: ${message.body}',
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotification.initialize(flutterLocalNotificationsPlugin);

  await Permissions().askSMSPermission();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager()
      .registerOneOffTask(Utility().generateRandomString(10), taskName);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}
