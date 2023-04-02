import 'package:device_info_plus/device_info_plus.dart';

// ignore: avoid_classes_with_only_static_members
class DeviceInfo {
  static late bool isIosSimulator;

  static Future<void> checkIosSimulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    isIosSimulator = iosInfo.systemName == 'iOS' && !iosInfo.isPhysicalDevice;
  }
}
