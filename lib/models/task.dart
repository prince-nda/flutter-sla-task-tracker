/// Workflow status chosen by the user.
enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

/// Status computed automatically from deadline + completion (never stored).
enum SlaStatus { onTrack, atRisk, overdue, completed }

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'To Do',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
      };
}

extension TaskPriorityLabel on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };
}

extension SlaStatusLabel on SlaStatus {
  String get label => switch (this) {
        SlaStatus.onTrack => 'On Track',
        SlaStatus.atRisk => 'At Risk',
        SlaStatus.overdue => 'Overdue',
        SlaStatus.completed => 'Completed',
      };
}

class Task {
  final String id;
  final String title;
  final String description;
  final String assigneeId;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String notes;
  final DateTime createdAt;

  /// Used for the dashboard's "Recent Activity" feed.
  final DateTime updatedAt;
  final String? updatedBy;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.assigneeId,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.notes = '',
    required this.createdAt,
    DateTime? updatedAt,
    this.updatedBy,
  }) : updatedAt = updatedAt ?? createdAt;

  /// Every edit stamps updatedAt/updatedBy so activity can be shown.
  Task copyWith({
    String? title,
    String? description,
    String? assigneeId,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? notes,
    String? updatedBy,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        assigneeId: assigneeId ?? this.assigneeId,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        updatedBy: updatedBy ?? this.updatedBy,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'assigneeId': assigneeId,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'updatedBy': updatedBy,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final created = DateTime.parse(json['createdAt'] as String);
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      assigneeId: json['assigneeId'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      notes: (json['notes'] ?? '') as String,
      createdAt: created,
      updatedAt: json['updatedAt'] == null
          ? created
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );
  }
}
