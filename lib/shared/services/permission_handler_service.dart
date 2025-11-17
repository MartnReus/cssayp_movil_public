import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  final DeviceInfoPlugin deviceInfo;
  PermissionHandlerService({required this.deviceInfo});

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion < 30) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }
}
