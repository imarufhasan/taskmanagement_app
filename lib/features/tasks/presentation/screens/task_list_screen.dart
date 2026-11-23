import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_filter.dart';
import 'package:taskmanagement_app/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskmanagement_app/features/tasks/presentation/screens/widgets/task_card.dart';
import 'package:taskmanagement_app/features/tasks/presentation/screens/widgets/task_filter_sheet.dart';
import 'package:taskmanagement_app/shared/widgets/empty_state_view.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(taskListProvider.notifier).loadNextPage();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TaskFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);
    final filter = ref.watch(taskFilterProvider);
    final hasSearch = filter.search != null && filter.search!.trim().isNotEmpty;
    final hasActiveFilter = filter.status != null ||
        filter.priority != null ||
        filter.overdue == true ||
        hasSearch ||
        filter.sort != 'newest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _openFilterSheet,
                tooltip: 'Filter & Sort',
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks by title or details...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(taskFilterProvider.notifier).state =
                              filter.copyWith(search: null, page: 1);
                          ref.read(taskListProvider.notifier).loadTasks();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {});
                if (val.trim().isEmpty && filter.search != null) {
                  ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(search: null, page: 1);
                  ref.read(taskListProvider.notifier).loadTasks();
                }
              },
              onSubmitted: (val) {
                ref.read(taskFilterProvider.notifier).state =
                    filter.copyWith(search: val.trim().isEmpty ? null : val.trim(), page: 1);
                ref.read(taskListProvider.notifier).loadTasks();
              },
            ),
          ),

          // Active filter badges indicator
          if (hasActiveFilter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Filtered by: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (hasSearch)
                    _ActiveFilterChip(label: 'Search: "${filter.search}"'),
                  if (filter.status != null)
                    _ActiveFilterChip(label: filter.status!),
                  if (filter.priority != null)
                    _ActiveFilterChip(label: filter.priority!),
                  if (filter.overdue == true)
                    const _ActiveFilterChip(label: 'Overdue'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(taskFilterProvider.notifier).state = const TaskFilter();
                      ref.read(taskListProvider.notifier).loadTasks();
                      setState(() {});
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Task List Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(refresh: true),
              child: taskState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskState.tasks.isEmpty
                      ? EmptyStateView(
                          title: 'No Tasks Found',
                          subtitle: hasActiveFilter
                              ? 'Try adjusting your filters or search keywords.'
                              : 'Tap the button below to add your first task!',
                          icon: Icons.checklist_rounded,
                          actionLabel: hasActiveFilter ? 'Clear Filters' : 'Create Task',
                          onAction: () {
                            if (hasActiveFilter) {
                              _searchController.clear();
                              ref.read(taskFilterProvider.notifier).state =
                                  const TaskFilter();
                              ref.read(taskListProvider.notifier).loadTasks();
                              setState(() {});
                            } else {
                              context.push('/tasks/create');
                            }
                          },
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: taskState.tasks.length + (taskState.isPaginating ? 1 : 0),
                          itemBuilder: (ctx, idx) {
                            if (idx < taskState.tasks.length) {
                              final task = taskState.tasks[idx];
                              return TaskCard(task: task);
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;

  const _ActiveFilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
