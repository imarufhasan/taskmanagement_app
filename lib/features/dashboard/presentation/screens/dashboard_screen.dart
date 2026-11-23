import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_model.dart';
import 'package:taskmanagement_app/features/tasks/presentation/providers/task_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final statsAsync = ref.watch(taskStatsProvider);
    final taskListState = ref.watch(taskListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.name ?? 'User'} 👋',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              dateString,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(taskStatsProvider);
          await ref.read(taskListProvider.notifier).loadTasks();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              statsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.priorityUrgent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.priorityUrgent),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Failed to load stats: $err')),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => ref.invalidate(taskStatsProvider),
                      ),
                    ],
                  ),
                ),
                data: (stats) {
                  final totalTasks = stats.totalTasks;
                  final completedTasks = stats.completedTasks;
                  final inProgressTasks = stats.inProgressTasks;
                  final pendingTasks = stats.pendingTasks;
                  final overdueTasks = stats.overdueTasks;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Tasks',
                              count: totalTasks,
                              icon: Icons.list_alt_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Completed',
                              count: completedTasks,
                              icon: Icons.check_circle_outline,
                              color: AppColors.statusCompleted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'In Progress',
                              count: inProgressTasks,
                              icon: Icons.timelapse_rounded,
                              color: AppColors.statusInProgress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Pending',
                              count: pendingTasks,
                              icon: Icons.hourglass_top_rounded,
                              color: AppColors.statusPending,
                            ),
                          ),
                        ],
                      ),
                      if (overdueTasks > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.priorityUrgent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.priorityUrgent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.priorityUrgent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You have $overdueTasks overdue tasks!',
                                  style: const TextStyle(
                                    color: AppColors.priorityUrgent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/tasks'),
                                child: const Text('View'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.go('/tasks'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (taskListState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (taskListState.tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No tasks yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create your first task to get started!',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/tasks/create'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create Task'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: taskListState.tasks.take(4).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final task = taskListState.tasks[idx];
                    return _RecentTaskTile(task: task);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTaskTile extends ConsumerWidget {
  final TaskModel task;

  const _RecentTaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == 'completed';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: ListTile(
        onTap: () => context.push('/tasks/${task.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Checkbox(
          value: isCompleted,
          activeColor: AppColors.statusCompleted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            final newStatus = (val == true) ? 'completed' : 'pending';
            ref.read(taskListProvider.notifier).updateStatus(task, newStatus);
          },
        ),
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Colors.grey
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
        subtitle: task.dueDate != null
            ? Text(
                'Due: ${DateFormat('MMM dd').format(task.dueDate!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }
}
