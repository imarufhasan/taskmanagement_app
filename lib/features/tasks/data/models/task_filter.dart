const _sentinel = Object();

class TaskFilter {
  final String? search;
  final String? status; // 'all', 'pending', 'in-progress', 'completed'
  final String? priority; // 'all', 'low', 'medium', 'high', 'urgent'
  final bool? overdue;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sort; // 'newest', 'oldest', 'dueDate', 'title', 'priority'
  final int page;
  final int limit;

  const TaskFilter({
    this.search,
    this.status,
    this.priority,
    this.overdue,
    this.startDate,
    this.endDate,
    this.sort = 'newest',
    this.page = 1,
    this.limit = 15,
  });

  TaskFilter copyWith({
    Object? search = _sentinel,
    Object? status = _sentinel,
    Object? priority = _sentinel,
    Object? overdue = _sentinel,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
    String? sort,
    int? page,
    int? limit,
  }) {
    return TaskFilter(
      search: identical(search, _sentinel) ? this.search : search as String?,
      status: identical(status, _sentinel) ? this.status : status as String?,
      priority: identical(priority, _sentinel) ? this.priority : priority as String?,
      overdue: identical(overdue, _sentinel) ? this.overdue : overdue as bool?,
      startDate: identical(startDate, _sentinel) ? this.startDate : startDate as DateTime?,
      endDate: identical(endDate, _sentinel) ? this.endDate : endDate as DateTime?,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
    };

    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }
    if (status != null && status!.isNotEmpty && status != 'all') {
      params['status'] = status;
    }
    if (priority != null && priority!.isNotEmpty && priority != 'all') {
      params['priority'] = priority;
    }
    if (overdue == true) {
      params['overdue'] = 'true';
    }
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }

    return params;
  }
}
