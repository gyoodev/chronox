import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  final Dio _dio = Dio();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> createSession() async {
    try {
      // Get IP address
      final ipAddress = await _getIpAddress();

      // Get device info
      String deviceModel;
      String deviceVersion;
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        deviceVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        deviceVersion = iosInfo.systemVersion;
      } else {
        deviceModel = 'Unknown';
        deviceVersion = 'Unknown';
      }

      // Store session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ipAddress', ipAddress);
      await prefs.setString('deviceModel', deviceModel);
      await prefs.setString('deviceVersion', deviceVersion);

      print('Session created successfully:');
      print('IP Address: $ipAddress');
      print('Device Model: $deviceModel');
      print('Device Version: $deviceVersion');

    } catch (e) {
      print('Error creating session: $e');
    }
  }

  Future<String> _getIpAddress() async {
    try {
      final response = await _dio.get('https://api.ipify.org');
      return response.data;
    } catch (e) {
      print('Error getting IP address: $e');
      return 'Unknown';
    }
  }
}
