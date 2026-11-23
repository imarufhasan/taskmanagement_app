import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/task_card.dart';
import '../auth/login_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

  List<TaskModel> _tasks = [];
  TaskStats _stats = TaskStats();
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'pending', 'in-progress', 'completed'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _taskService.getTasks(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
          search: _searchQuery.isEmpty ? null : _searchQuery,
        ),
        _taskService.getStatistics(),
      ]);

      if (mounted) {
        setState(() {
          _tasks = results[0] as List<TaskModel>;
          _stats = results[1] as TaskStats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStatusChange(TaskModel task, String newStatus) async {
    // Optimistic UI update
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      setState(() {
        _tasks[index] = task.copyWith(status: newStatus);
      });
    }

    await _taskService.updateTaskStatus(task.id, newStatus);
    _loadData();
  }

  Future<void> _handleDelete(String taskId) async {
    final deleted = await _taskService.deleteTask(taskId);
    if (deleted || true) {
      setState(() {
        _tasks.removeWhere((t) => t.id == taskId);
      });
      _loadData();
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Manager',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (user != null)
              Text(
                'Hello, ${user.name}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // Stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  StatsCard(
                    title: 'Total',
                    count: _stats.totalTasks > 0 ? _stats.totalTasks : _tasks.length,
                    icon: Icons.list_alt_rounded,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  StatsCard(
                    title: 'Pending',
                    count: _stats.pendingTasks,
                    icon: Icons.hourglass_empty_rounded,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  StatsCard(
                    title: 'In Progress',
                    count: _stats.inProgressTasks,
                    icon: Icons.run_circle_outlined,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  StatsCard(
                    title: 'Completed',
                    count: _stats.completedTasks,
                    icon: Icons.check_circle_outline,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadData();
                          },
                        )
                      : null,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSubmitted: (val) {
                  setState(() => _searchQuery = val.trim());
                  _loadData();
                },
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', 'in-progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Task List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No tasks found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap the + button below to create one!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return TaskCard(
                              task: task,
                              onStatusChanged: (newStatus) {
                                _handleStatusChange(task, newStatus);
                              },
                              onDelete: () {
                                _handleDelete(task.id);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
          if (result != null) {
            if (result is TaskModel) {
              setState(() => _tasks.insert(0, result));
            }
            _loadData();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
          _loadData();
        }
      },
    );
  }
}
