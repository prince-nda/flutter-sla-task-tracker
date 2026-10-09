import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class CreateEditTaskScreen extends StatefulWidget {
  final Task? task; // null = create
  final List<TeamMember> members;

  const CreateEditTaskScreen({super.key, this.task, required this.members});

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskStatus _status;
  late TaskPriority _priority;
  late DateTime _dueDate;
  String? _assigneeId;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? TaskStatus.todo;
    _priority = t?.priority ?? TaskPriority.medium;
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _assigneeId = t?.assigneeId;
    // Guard against an assignee that no longer exists.
    if (_assigneeId != null &&
        !widget.members.any((m) => m.id == _assigneeId)) {
      _assigneeId = null;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (time == null) return;
    setState(() {
      _dueDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final existing = widget.task;

    DateTime? completedAt;
    if (_status == TaskStatus.completed) {
      completedAt = existing?.completedAt ?? now;
    }

    final task = Task(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      status: _status,
      priority: _priority,
      createdAt: existing?.createdAt ?? now,
      dueDate: _dueDate,
      completedAt: completedAt,
      assigneeId: _assigneeId,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'New Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: TaskStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) => setState(() => _priority = v ?? _priority),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              value: _assigneeId,
              decoration: const InputDecoration(labelText: 'Assignee'),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('Unassigned')),
                ...widget.members.map(
                  (m) => DropdownMenuItem<String?>(
                      value: m.id, child: Text(m.name)),
                ),
              ],
              onChanged: (v) => setState(() => _assigneeId = v),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(Format.dateTime(_dueDate)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Save changes' : 'Create task'),
            ),
          ],
        ),
      ),
    );
  }
}