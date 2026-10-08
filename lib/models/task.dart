enum TaskStatus { todo, inProgress, completed }

enum TaskPriority { low, medium, high }

extension TaskStatusLabel on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

extension TaskPriorityLabel on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? completedAt;
  final String? assigneeId;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    required this.dueDate,
    this.completedAt,
    this.assigneeId,
  });

  bool get isCompleted => status == TaskStatus.completed;

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    String? assigneeId,
    bool clearCompletedAt = false,
    bool clearAssignee = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'assigneeId': assigneeId,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        status: TaskStatus.values.byName(json['status'] as String),
        priority: TaskPriority.values.byName(json['priority'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        assigneeId: json['assigneeId'] as String?,
      );
}