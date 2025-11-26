import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceDetails {
  final String id;
  final String model;
  final String platform;

  DeviceDetails({
    required this.id,
    required this.model,
    required this.platform,
  });
}

class ApiServices {
  static Future<DeviceDetails> fetchDeviceDetails() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return DeviceDetails(
          id: androidInfo.id,
          model: androidInfo.model,
          platform: 'Android',
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return DeviceDetails(
          id: iosInfo.identifierForVendor ?? 'unknown',
          model: iosInfo.model,
          platform: 'iOS',
        );
      } else {
        return DeviceDetails(
          id: 'unknown',
          model: 'unknown',
          platform: 'unknown',
        );
      }
    } catch (e) {
      debugPrint('Error fetching device details: $e');
      return DeviceDetails(
        id: 'error',
        model: 'error',
        platform: 'error',
      );
    }
  }
}
