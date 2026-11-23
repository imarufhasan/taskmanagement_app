import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable base host. Defaults to live cloud server.
  static String? customHost;

  // Live Production Server URL deployed on Render
  static const String liveBaseUrl = 'https://task-manager-api-p4jk.onrender.com';

  static String get baseUrl {
    if (customHost != null && customHost!.trim().isNotEmpty) {
      final host = customHost!.trim();
      return host.startsWith('http') ? '$host/api' : 'http://$host:5000/api';
    }

    return '$liveBaseUrl/api';
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
