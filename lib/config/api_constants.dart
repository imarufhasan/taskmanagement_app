import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/Web/Desktop, or custom IP for physical device
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Task endpoints
  static const String createTask = '/tasks/create';
  static const String getMyTasks = '/tasks/getMyTasks';
  static const String statistics = '/tasks/statistics';
  static String taskById(String id) => '/tasks/$id';
  static String updateStatus(String id) => '/tasks/$id/status';
}
