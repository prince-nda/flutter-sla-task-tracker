import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/task_actions.dart';
import '../widgets/member_avatar.dart';
import '../widgets/sla_badge.dart';
import 'create_edit_task_screen.dart';

/// Keeps its own copy of the task (_task) because this screen is pushed on
/// top of the list: after every change we call onSaveTask (updates AppRoot
/// + storage) AND setState here so this screen refreshes immediately.
class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final List<TeamMember> members;
  final TeamMember currentUser;
  final void Function(Task) onSaveTask;
  final void Function(String taskId) onDeleteTask;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.members,
    required this.currentUser,
    required this.onSaveTask,
    required this.onDeleteTask,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task = widget.task;
  late final _notesCtrl = TextEditingController(text: widget.task.notes);

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _update(Task updated) {
    widget.onSaveTask(updated);
    setState(() => _task = updated);
  }

  Future<void> _edit() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEditTaskScreen(
          task: _task,
          members: widget.members,
          currentUser: widget.currentUser,
        ),
      ),
    );
    if (result == null || !mounted) return;
    _update(result);
    _notesCtrl.text = result.notes;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Task updated')));
  }

  Future<void> _delete() async {
    final deleted = await confirmDeleteTask(context, _task, widget.onDeleteTask);
    if (deleted && mounted) Navigator.pop(context);
  }

  void _saveNotes() {
    _update(_task.copyWith(
        notes: _notesCtrl.text.trim(), updatedBy: widget.currentUser.id));
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Notes saved')));
  }

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.statusOf(_task);
    final slaColor = AppColors.forSla(sla);
    final assignee = findMember(widget.members, _task.assigneeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? _edit() : _delete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(_task.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.sm),
              SlaBadge(status: sla),
            ],
          ),
          if (_task.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_task.description,
                style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: AppSpacing.md),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                children: [
                  _row(
                    Icons.person_add_alt_1_outlined,
                    'Assigned to',
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      MemberAvatar(member: assignee, radius: 14),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                          child: Text(assignee?.name ?? 'Unassigned',
                              overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                  _row(Icons.calendar_today_outlined, 'Due Date',
                      Text(formatDate(_task.dueDate))),
                  _row(
                    Icons.flag_outlined,
                    'Priority',
                    Text(_task.priority.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: switch (_task.priority) {
                              TaskPriority.high => AppColors.overdue,
                              TaskPriority.medium => AppColors.atRisk,
                              TaskPriority.low => AppColors.onTrack,
                            })),
                  ),
                  _row(
                    Icons.list_alt_outlined,
                    'Status',
                    DropdownButton<TaskStatus>(
                      value: _task.status,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final s in TaskStatus.values)
                          DropdownMenuItem(value: s, child: Text(s.label)),
                      ],
                      onChanged: (s) {
                        if (s == null) return;
                        _update(_task.copyWith(
                            status: s, updatedBy: widget.currentUser.id));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // SLA status card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: slaColor.withAlpha(36),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: slaColor.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SLA Status',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  Icon(AppColors.iconForSla(sla), color: slaColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text(sla.label,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: AppSpacing.xs),
                Text(SlaService.explain(_task)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          const Text('Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesCtrl,
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(hintText: 'Add any additional notes...'),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _saveNotes,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save notes'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton(onPressed: _edit, child: const Text('Edit Task')),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.blue),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 96,
              child: Text(label, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
          ],
        ),
      );
}
