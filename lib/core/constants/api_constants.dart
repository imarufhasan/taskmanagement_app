import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable base host. Defaults to smart platform detection.
  static String? customHost;

  // Your PC's LAN IPv4 address (from ipconfig)
  static const String pcLanIp = '10.10.28.100';

  static String get baseUrl {
    if (customHost != null && customHost!.trim().isNotEmpty) {
      final host = customHost!.trim();
      return host.startsWith('http') ? '$host/api' : 'http://$host:5000/api';
    }

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    try {
      if (Platform.isAndroid) {
        // Physical Android device connects directly to your PC's IP:
        return 'http://$pcLanIp:5000/api';
      }
    } catch (_) {}

    return 'http://localhost:5000/api';
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String users = '/auth/users';

  // Task endpoints
  static const String createTask = '/tasks/create';
  static const String getMyTasks = '/tasks/getMyTasks';
  static const String statistics = '/tasks/statistics';
  static String taskById(String id) => '/tasks/$id';
  static String updateStatus(String id) => '/tasks/$id/status';
}
