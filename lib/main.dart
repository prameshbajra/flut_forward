import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_codelab/local_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

const taskName = 'task';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    print("SMS: WORKER MANAGER CALLED");
    final Telephony telephony = Telephony.backgroundInstance;
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          print("SMS: Reading ... Foreground ...");
          print(message.address);
          print(message.body);
          print(message.date);
          LocalNotification.showNotification(
              title: 'Forwarder',
              body: 'Reading SMS Foreground',
              flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
        },
        listenInBackground: true,
        onBackgroundMessage: backgrounMessageHandler);
    return Future.value(true);
  });
}

backgrounMessageHandler(SmsMessage message) async {
  print("SMS: Reading ... Background I think ...");
  print(message.address);
  print(message.body);
  print(message.date);
  LocalNotification.showNotification(
      title: 'Forwarder',
      body: 'Reading SMS Background',
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerOneOffTask(generateRandomString(10), "task",
      initialDelay: Duration(seconds: 10));
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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    LocalNotification.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Listen Incoming SMS in Flutter"),
          backgroundColor: Colors.redAccent),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
            "I do not know how to create a Flutter app. This is a weekend project and I want to get the functionality working."),
      ),
    );
  }
}
