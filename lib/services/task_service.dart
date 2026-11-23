import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/task_model.dart';
import 'auth_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final AuthService _auth = AuthService();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_auth.token != null) 'Authorization': 'Bearer ${_auth.token}',
      };

  Future<List<TaskModel>> getTasks({
    String? status,
    String? search,
    String? priority,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (priority != null && priority.isNotEmpty && priority != 'all') {
        queryParams['priority'] = priority;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getMyTasks}')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tasks'] is List) {
          return (data['tasks'] as List)
              .map((json) => TaskModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<TaskStats> getStatistics() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.statistics}');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return TaskStats.fromJson(body['data']);
        }
      }
      return TaskStats();
    } catch (_) {
      return TaskStats();
    }
  }

  Future<Map<String, dynamic>> createTask(TaskModel task) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createTask}');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(task.toJson()),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || (data['status'] == true)) {
        return {'success': true, 'task': TaskModel.fromJson(data['task'])};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to create task'};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateStatus(taskId)}');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode({'status': newStatus}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.taskById(taskId)}');
      final response = await http.delete(uri, headers: _headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
