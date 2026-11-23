import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_model.dart';
import 'package:taskmanagement_app/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskmanagement_app/features/tasks/presentation/screens/widgets/task_card.dart';
import 'package:taskmanagement_app/shared/widgets/empty_state_view.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<TaskModel> _getTasksForDay(DateTime day, List<TaskModel> allTasks) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);
    final allTasks = taskState.tasks;
    final selectedDayTasks = _selectedDay != null
        ? _getTasksForDay(_selectedDay!, allTasks)
        : <TaskModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar<TaskModel>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) => _getTasksForDay(day, allTasks),
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay != null
                      ? 'Tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                      : 'Select a Date',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${selectedDayTasks.length} tasks',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedDayTasks.isEmpty
                ? EmptyStateView(
                    title: 'No Tasks For This Date',
                    subtitle: 'Enjoy your free time or schedule a new task!',
                    icon: Icons.event_available_rounded,
                    actionLabel: 'Add Task For Today',
                    onAction: () => context.push('/tasks/create'),
                  )
                : ListView.builder(
                    itemCount: selectedDayTasks.length,
                    itemBuilder: (ctx, idx) {
                      final task = selectedDayTasks[idx];
                      return TaskCard(task: task);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
