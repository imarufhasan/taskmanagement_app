class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'pending', 'in-progress', 'completed'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.status = 'pending',
    this.priority = 'medium',
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PriorityStats {
  final int high;
  final int medium;
  final int low;
  final int urgent;

  const PriorityStats({
    this.high = 0,
    this.medium = 0,
    this.low = 0,
    this.urgent = 0,
  });

  factory PriorityStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PriorityStats();
    return PriorityStats(
      high: json['highPriorityTasks'] ?? 0,
      medium: json['mediumPriorityTasks'] ?? 0,
      low: json['lowPriorityTasks'] ?? 0,
      urgent: json['urgentPriorityTasks'] ?? 0,
    );
  }
}

class TaskStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final PriorityStats priority;

  const TaskStats({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.inProgressTasks = 0,
    this.overdueTasks = 0,
    this.priority = const PriorityStats(),
  });

  factory TaskStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TaskStats();
    return TaskStats(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      inProgressTasks: json['inProgressTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      priority: PriorityStats.fromJson(json['priority'] as Map<String, dynamic>?),
    );
  }
}
