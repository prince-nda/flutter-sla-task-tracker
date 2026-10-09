import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/task_actions.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final List<TeamMember> members;
  final ValueChanged<Task> onUpdate;
  final ValueChanged<String> onDelete; // receives the task id

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.members,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  TeamMember? get _assignee {
    for (final m in widget.members) {
      if (m.id == _task.assigneeId) return m;
    }
    return null;
  }

  Future<void> _edit() async {
    final updated = await TaskActions.openForm(
      context,
      task: _task,
      members: widget.members,
    );
    if (updated == null) return;
    setState(() => _task = updated);
    widget.onUpdate(updated);
  }

  void _markComplete() {
    final updated = _task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
    setState(() => _task = updated);
    widget.onUpdate(updated);
  }

  Future<void> _delete() async {
    final ok = await TaskActions.confirmDelete(context, _task);
    if (!ok || !mounted) return;
    widget.onDelete(_task.id);
    Navigator.of(context).pop();
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.evaluate(_task);
    final color = AppTheme.slaColor(sla);
    final remaining = SlaService.timeRemaining(_task);

    String slaDetail;
    if (sla == SlaState.completed) {
      slaDetail = _task.completedAt == null
          ? 'Completed'
          : 'Completed ${Format.timeAgo(_task.completedAt!)}';
    } else if (remaining.isNegative) {
      slaDetail = 'Overdue since ${Format.dateTime(_task.dueDate)}';
    } else {
      slaDetail = 'Due ${Format.timeAgo(_task.dueDate)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: _edit),
          IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(_task.title,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(SlaService.label(sla),
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: color,
              side: BorderSide.none,
            ),
          ),
          Text(slaDetail, style: TextStyle(color: color)),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _row('Description',
                      _task.description.isEmpty ? '—' : _task.description),
                  _row('Status', _task.status.label),
                  _row('Priority', _task.priority.label),
                  _row('Assignee', _assignee?.name ?? 'Unassigned'),
                  _row('Due', Format.dateTime(_task.dueDate)),
                  _row('Created', Format.dateTime(_task.createdAt)),
                  if (_task.completedAt != null)
                    _row('Completed', Format.dateTime(_task.completedAt!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!_task.isCompleted)
            FilledButton.icon(
              onPressed: _markComplete,
              icon: const Icon(Icons.check),
              label: const Text('Mark as completed'),
            ),
        ],
      ),
    );
  }
}