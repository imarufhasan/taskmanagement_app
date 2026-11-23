import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/core/utils/date_utils.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_model.dart';
import 'package:taskmanagement_app/features/tasks/presentation/providers/task_provider.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
      default:
        return AppColors.priorityLow;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.statusCompleted;
      case 'in-progress':
        return AppColors.statusInProgress;
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailsProvider(taskId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          taskAsync.maybeWhen(
            data: (task) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Task',
              onPressed: () => context.push('/tasks/${task.id}/edit'),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.priorityUrgent),
            tooltip: 'Delete Task',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Failed to load task details: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(taskDetailsProvider(taskId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (task) {
          final priorityColor = _getPriorityColor(task.priority);
          final statusColor = _getStatusColor(task.status);
          final isOverdue = AppDateUtils.isOverdue(task.dueDate, task.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.status.replaceAll('-', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 14, color: priorityColor),
                          const SizedBox(width: 4),
                          Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOverdue ? Icons.warning_amber_rounded : Icons.calendar_month_outlined,
                        color: isOverdue ? AppColors.priorityUrgent : AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            task.dueDate != null
                                ? AppDateUtils.formatDisplay(task.dueDate)
                                : 'No Due Date Set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isOverdue ? AppColors.priorityUrgent : null,
                            ),
                          ),
                        ],
                      ),
                      if (isOverdue) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.priorityUrgent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.priorityUrgent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    task.description.isNotEmpty
                        ? task.description
                        : 'No description provided for this task.',
                    style: TextStyle(
                      fontSize: 14,
                      color: task.description.isNotEmpty
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                          : Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Change Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatusOptionButton(
                        label: 'Pending',
                        isSelected: task.status == 'pending',
                        color: AppColors.statusPending,
                        onTap: () => _updateStatus(context, ref, task, 'pending'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatusOptionButton(
                        label: 'In Progress',
                        isSelected: task.status == 'in-progress',
                        color: AppColors.statusInProgress,
                        onTap: () => _updateStatus(context, ref, task, 'in-progress'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatusOptionButton(
                        label: 'Completed',
                        isSelected: task.status == 'completed',
                        color: AppColors.statusCompleted,
                        onTap: () => _updateStatus(context, ref, task, 'completed'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
    String newStatus,
  ) async {
    await ref.read(taskListProvider.notifier).updateStatus(task, newStatus);
    ref.invalidate(taskDetailsProvider(taskId));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.priorityUrgent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(taskListProvider.notifier).deleteTask(taskId);
              if (context.mounted && success) {
                context.pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusOptionButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
