import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PermissionController {
  const PermissionController();

  Future<bool> ensureLocationWhenInUse() async {
    if (kIsWeb) return true; // 웹은 브라우저 정책에 따르므로 앱 단계에선 패스

    // 서비스 상태는 호출자가 별도로 체크/안내 가능. 여기선 권한만 책임진다.
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    final result = await Permission.locationWhenInUse.request();
    if (result.isGranted) return true;

    // 필요 시 설정 화면 열기 유도
    if (result.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }
}
