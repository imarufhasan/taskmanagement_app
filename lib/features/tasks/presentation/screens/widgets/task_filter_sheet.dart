import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_filter.dart';
import 'package:taskmanagement_app/features/tasks/presentation/providers/task_provider.dart';

class TaskFilterSheet extends ConsumerStatefulWidget {
  const TaskFilterSheet({super.key});

  @override
  ConsumerState<TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends ConsumerState<TaskFilterSheet> {
  late String _status;
  late String _priority;
  late String _sort;
  late bool _overdue;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(taskFilterProvider);
    _status = filter.status ?? 'all';
    _priority = filter.priority ?? 'all';
    _sort = filter.sort;
    _overdue = filter.overdue == true;
  }

  void _applyFilter() {
    final currentFilter = ref.read(taskFilterProvider);
    final updated = currentFilter.copyWith(
      status: _status == 'all' ? null : _status,
      priority: _priority == 'all' ? null : _priority,
      sort: _sort,
      overdue: _overdue ? true : null,
      page: 1,
    );

    ref.read(taskFilterProvider.notifier).state = updated;
    ref.read(taskListProvider.notifier).loadTasks();
    Navigator.pop(context);
  }

  void _resetFilter() {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter();
    ref.read(taskListProvider.notifier).loadTasks();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetFilter,
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const Divider(),

            // Status Filter
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildChoiceChip('All', 'all', _status, (v) => setState(() => _status = v)),
                _buildChoiceChip('Pending', 'pending', _status, (v) => setState(() => _status = v)),
                _buildChoiceChip('In Progress', 'in-progress', _status, (v) => setState(() => _status = v)),
                _buildChoiceChip('Completed', 'completed', _status, (v) => setState(() => _status = v)),
              ],
            ),
            const SizedBox(height: 16),

            // Priority Filter
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildChoiceChip('All', 'all', _priority, (v) => setState(() => _priority = v)),
                _buildChoiceChip('Low', 'low', _priority, (v) => setState(() => _priority = v)),
                _buildChoiceChip('Medium', 'medium', _priority, (v) => setState(() => _priority = v)),
                _buildChoiceChip('High', 'high', _priority, (v) => setState(() => _priority = v)),
                _buildChoiceChip('Urgent', 'urgent', _priority, (v) => setState(() => _priority = v)),
              ],
            ),
            const SizedBox(height: 16),

            // Sort By
            const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildChoiceChip('Newest', 'newest', _sort, (v) => setState(() => _sort = v)),
                _buildChoiceChip('Oldest', 'oldest', _sort, (v) => setState(() => _sort = v)),
                _buildChoiceChip('Due Date', 'dueDate', _sort, (v) => setState(() => _sort = v)),
                _buildChoiceChip('Priority', 'priority', _sort, (v) => setState(() => _sort = v)),
                _buildChoiceChip('Title', 'title', _sort, (v) => setState(() => _sort = v)),
              ],
            ),
            const SizedBox(height: 16),

            // Overdue Only Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Overdue Tasks Only', style: TextStyle(fontSize: 14)),
              value: _overdue,
              activeThumbColor: AppColors.priorityUrgent,
              onChanged: (val) => setState(() => _overdue = val),
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilter,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    String value,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isSelected = currentValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
    );
  }
}
