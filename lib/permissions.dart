import 'package:permission_handler/permission_handler.dart';

class Permissions {
  Future<bool> askSMSPermission() async {
    PermissionStatus status = await Permission.sms.request();
    if (status.isDenied) {
      print("Permission message denied");
      askSMSPermission();
    } else {
      print("Permission message granted");
      return true;
    }
    print("Permission message denied weirdly.");
    return false;
  }

  Future<bool> askNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isDenied) {
      print("Permission notfication denied");
      askSMSPermission();
    } else {
      print("Permission notfication granted");
      return true;
    }
    print("Permission notfication denied weirdly.");
    return false;
  }
}
