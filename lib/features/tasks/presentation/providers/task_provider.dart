import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_filter.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_model.dart';
import 'package:taskmanagement_app/features/tasks/data/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaskRepository(apiClient: apiClient);
});

// Task Filter State
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});

// Task List State
class TaskListState {
  final bool isLoading;
  final bool isPaginating;
  final List<TaskModel> tasks;
  final int total;
  final int totalPages;
  final String? errorMessage;

  const TaskListState({
    this.isLoading = false,
    this.isPaginating = false,
    this.tasks = const [],
    this.total = 0,
    this.totalPages = 1,
    this.errorMessage,
  });

  TaskListState copyWith({
    bool? isLoading,
    bool? isPaginating,
    List<TaskModel>? tasks,
    int? total,
    int? totalPages,
    String? errorMessage,
  }) {
    return TaskListState(
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      tasks: tasks ?? this.tasks,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage,
    );
  }
}

class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskListNotifier(this._repository, this._ref) : super(const TaskListState()) {
    loadTasks();
  }

  Future<void> loadTasks({bool refresh = false}) async {
    final filter = _ref.read(taskFilterProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _repository.getTasks(filter);
      state = state.copyWith(
        isLoading: false,
        tasks: result['tasks'] as List<TaskModel>,
        total: result['total'] as int,
        totalPages: result['totalPages'] as int,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    final filter = _ref.read(taskFilterProvider);
    if (filter.page >= state.totalPages || state.isPaginating || state.isLoading) {
      return;
    }

    state = state.copyWith(isPaginating: true);
    final nextPage = filter.page + 1;
    _ref.read(taskFilterProvider.notifier).state = filter.copyWith(page: nextPage);

    try {
      final result = await _repository.getTasks(filter.copyWith(page: nextPage));
      final newTasks = result['tasks'] as List<TaskModel>;

      state = state.copyWith(
        isPaginating: false,
        tasks: [...state.tasks, ...newTasks],
        total: result['total'] as int,
        totalPages: result['totalPages'] as int,
      );
    } catch (_) {
      state = state.copyWith(isPaginating: false);
    }
  }

  Future<void> updateStatus(TaskModel task, String newStatus) async {
    final oldTasks = [...state.tasks];
    final index = state.tasks.indexWhere((t) => t.id == task.id);

    if (index != -1) {
      final updatedList = [...state.tasks];
      updatedList[index] = task.copyWith(status: newStatus);
      state = state.copyWith(tasks: updatedList);
    }

    try {
      await _repository.updateTaskStatus(task.id, newStatus);
      _ref.invalidate(taskStatsProvider);
    } catch (e) {
      state = state.copyWith(tasks: oldTasks, errorMessage: 'Failed to update status: $e');
    }
  }

  Future<bool> deleteTask(String id) async {
    final oldTasks = [...state.tasks];
    state = state.copyWith(tasks: state.tasks.where((t) => t.id != id).toList());

    try {
      await _repository.deleteTask(id);
      _ref.invalidate(taskStatsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(tasks: oldTasks, errorMessage: 'Failed to delete task: $e');
      return false;
    }
  }

  void refreshAfterMutation() {
    loadTasks();
    _ref.invalidate(taskStatsProvider);
  }
}

final taskListProvider = StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(repo, ref);
});

// Task Statistics Provider
final taskStatsProvider = FutureProvider<TaskStats>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getStatistics();
});

// Single Task Details Provider
final taskDetailsProvider = FutureProvider.family<TaskModel, String>((ref, id) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getTaskById(id);
});
