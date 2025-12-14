import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestAudioPermission() async {
    if (Platform.isAndroid) {
      // Android 13+
      if (await Permission.audio.isGranted) {
        return true;
      }

      final status = await Permission.audio.request();
      return status.isGranted;
    }

    // iOS (nếu có)
    if (await Permission.mediaLibrary.isGranted) {
      return true;
    }
    final status = await Permission.mediaLibrary.request();
    return status.isGranted;
  }
}
