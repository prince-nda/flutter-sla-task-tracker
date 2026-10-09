import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// One form for both creating (task == null) and editing a task.
/// Returns the finished Task through Navigator.pop; the caller saves it.
///
/// Validation rules:
///  - Title: required, 3-60 characters
///  - Description: optional, max 300 characters
///  - Assignee: required
///  - Due date: required; cannot be in the past (when creating, or when an
///    edit changes the date) so a new task never starts out Overdue
class CreateEditTaskScreen extends StatefulWidget {
  final Task? task;
  final List<TeamMember> members;
  final TeamMember currentUser;

  const CreateEditTaskScreen({
    super.key,
    this.task,
    required this.members,
    required this.currentUser,
  });

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.task?.title);
  late final _descCtrl = TextEditingController(text: widget.task?.description);
  late final _dateCtrl = TextEditingController(
      text: widget.task == null ? '' : formatDate(widget.task!.dueDate));

  String? _assigneeId;
  DateTime? _dueDate;
  late TaskPriority _priority = widget.task?.priority ?? TaskPriority.medium;
  late TaskStatus _status = widget.task?.status ?? TaskStatus.todo;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _dueDate = t.dueDate;
      // Only preselect the assignee if that member still exists.
      if (widget.members.any((m) => m.id == t.assigneeId)) {
        _assigneeId = t.assigneeId;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final initial = _dueDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // Allow showing an existing past due date when editing.
      firstDate: initial.isBefore(today) ? initial : today,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dueDate = picked;
      _dateCtrl.text = formatDate(picked);
    });
    _formKey.currentState?.validate();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final due = dateOnly(_dueDate!);
    final existing = widget.task;

    final Task result = existing == null
        ? Task(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            assigneeId: _assigneeId!,
            dueDate: due,
            priority: _priority,
            status: _status,
            createdAt: DateTime.now(),
            updatedBy: widget.currentUser.id,
          )
        : existing.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            assigneeId: _assigneeId,
            dueDate: due,
            priority: _priority,
            status: _status,
            updatedBy: widget.currentUser.id,
          );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Task' : 'Create Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _label('Task Title'),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Enter task title'),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Title is required';
                if (t.length < 3) return 'Title must be at least 3 characters';
                if (t.length > 60) return 'Title must be 60 characters or less';
                return null;
              },
            ),
            _label('Description'),
            TextFormField(
              controller: _descCtrl,
              minLines: 3,
              maxLines: 5,
              decoration:
                  const InputDecoration(hintText: 'Enter task description'),
              validator: (v) => (v ?? '').trim().length > 300
                  ? 'Description must be 300 characters or less'
                  : null,
            ),
            _label('Assign To'),
            DropdownButtonFormField<String>(
              initialValue: _assigneeId,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Select team member',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: [
                for (final m in widget.members)
                  DropdownMenuItem(
                    value: m.id,
                    child: Text('${m.name} (${m.role})',
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _assigneeId = v),
              validator: (v) =>
                  v == null ? 'Please assign the task to a team member' : null,
            ),
            _label('Due Date'),
            TextFormField(
              controller: _dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                hintText: 'Select date',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                suffixIcon: Icon(Icons.edit_calendar_outlined),
              ),
              validator: (_) {
                final d = _dueDate;
                if (d == null) return 'Please select a due date';
                final changed =
                    !_isEdit || dateOnly(d) != dateOnly(widget.task!.dueDate);
                if (changed && dateOnly(d).isBefore(dateOnly(DateTime.now()))) {
                  return 'Due date cannot be in the past';
                }
                return null;
              },
            ),
            _label('Priority'),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration:
                  const InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
              items: [
                for (final p in TaskPriority.values)
                  DropdownMenuItem(value: p, child: Text(p.label)),
              ],
              onChanged: (v) => setState(() => _priority = v!),
            ),
            _label('Status'),
            DropdownButtonFormField<TaskStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.list_alt_outlined)),
              items: [
                for (final s in TaskStatus.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEdit ? 'Save Changes' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}
