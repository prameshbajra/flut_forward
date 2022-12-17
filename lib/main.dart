import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:telephony/telephony.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
        onStart: onAndroidStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationContent: 'SMS Reading mode ON.',
        foregroundServiceNotificationTitle: 'Forwarder'),
    iosConfiguration: IosConfiguration(
        onForeground: onIOSForeground, onBackground: onIOSBackground),
  );
  service.start();
}

void backgrounMessageHandler(SmsMessage message) async {
  print("SMS reading ... Background ...");
  print(message.address);
  print(message.body);
  print(message.date);
}

void onAndroidStart() {
  print("SMS reading ... Terminated ...");
  Telephony telephony = Telephony.instance;
  telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print("SMS reading ... Foreground ...");
        print(message.address);
        print(message.body);
        print(message.date);
      },
      listenInBackground: true,
      onBackgroundMessage: backgrounMessageHandler);
}

void onIOSForeground() {}

void onIOSBackground() {}

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
