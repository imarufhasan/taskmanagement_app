import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/task_filter.dart';
import 'models/task_model.dart';

class TaskRepository {
  final ApiClient apiClient;

  TaskRepository({required this.apiClient});

  Future<Map<String, dynamic>> getTasks(TaskFilter filter) async {
    final response = await apiClient.get(
      ApiConstants.getMyTasks,
      queryParameters: filter.toQueryParams(),
    );

    final rawList = response['tasks'] as List? ?? [];
    final tasks = rawList.map((j) => TaskModel.fromJson(j as Map<String, dynamic>)).toList();
    final total = response['total'] ?? tasks.length;
    final totalPages = response['totalPages'] ?? 1;

    return {
      'tasks': tasks,
      'total': total,
      'totalPages': totalPages,
    };
  }

  Future<TaskStats> getStatistics() async {
    final response = await apiClient.get(ApiConstants.statistics);
    return TaskStats.fromJson(response['data'] as Map<String, dynamic>?);
  }

  Future<TaskModel> getTaskById(String id) async {
    final response = await apiClient.get(ApiConstants.taskById(id));
    return TaskModel.fromJson(response['task']);
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await apiClient.post(
      ApiConstants.createTask,
      data: task.toJson(),
    );
    return TaskModel.fromJson(response['task']);
  }

  Future<TaskModel> updateTask(String id, Map<String, dynamic> updates) async {
    final response = await apiClient.put(
      ApiConstants.taskById(id),
      data: updates,
    );
    return TaskModel.fromJson(response['task']);
  }

  Future<TaskModel> updateTaskStatus(String id, String status) async {
    final response = await apiClient.put(
      ApiConstants.updateStatus(id),
      data: {'status': status},
    );
    return TaskModel.fromJson(response['task']);
  }

  Future<void> deleteTask(String id) async {
    await apiClient.delete(ApiConstants.taskById(id));
  }
}
