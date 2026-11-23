import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskmanagement_app/core/constants/app_colors.dart';
import 'package:taskmanagement_app/core/utils/date_utils.dart';
import 'package:taskmanagement_app/core/utils/validators.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_model.dart';
import 'package:taskmanagement_app/features/tasks/presentation/providers/task_provider.dart';
import 'package:taskmanagement_app/shared/widgets/app_button.dart';
import 'package:taskmanagement_app/shared/widgets/custom_text_field.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String _priority = 'medium';
  String _status = 'pending';
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.taskId != null) {
      _loadExistingTask();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingTask() async {
    setState(() => _isLoading = true);
    try {
      final task = await ref.read(taskRepositoryProvider).getTaskById(widget.taskId!);
      _titleController.text = task.title;
      _descController.text = task.description;
      _priority = task.priority;
      _status = task.status;
      _dueDate = task.dueDate;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = ref.read(taskRepositoryProvider);
    final isEditing = widget.taskId != null;

    try {
      if (isEditing) {
        await repo.updateTask(
          widget.taskId!,
          {
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'priority': _priority,
            'status': _status,
            'dueDate': _dueDate?.toIso8601String(),
          },
        );
        ref.invalidate(taskDetailsProvider(widget.taskId!));
      } else {
        final newTask = TaskModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _priority,
          status: _status,
          dueDate: _dueDate,
        );
        await repo.createTask(newTask);
      }

      ref.read(taskListProvider.notifier).refreshAfterMutation();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Task updated successfully!' : 'Task created successfully!'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.priorityUrgent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: _isLoading && isEditing && _titleController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Task Title *',
                        hint: 'e.g. Design app architecture',
                        prefixIcon: Icons.title_rounded,
                        validator: (val) => Validators.required(val, 'Title'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descController,
                        label: 'Description',
                        hint: 'Add notes, checklist or details...',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.flag_outlined, size: 20),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'low', child: Text('Low')),
                              DropdownMenuItem(value: 'medium', child: Text('Medium')),
                              DropdownMenuItem(value: 'high', child: Text('High')),
                              DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _priority = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.pending_actions_outlined, size: 20),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickDueDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Text(
                                    _dueDate != null
                                        ? AppDateUtils.formatDisplay(_dueDate)
                                        : 'Select due date (optional)',
                                    style: TextStyle(
                                      color: _dueDate != null ? null : Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_dueDate != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () => setState(() => _dueDate = null),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        text: isEditing ? 'Update Task' : 'Create Task',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
