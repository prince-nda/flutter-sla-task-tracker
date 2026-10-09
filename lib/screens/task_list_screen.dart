import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/task_actions.dart';
import '../widgets/task_card.dart';

/// Searchable, filterable list of tasks. Filtering is derived state: it is
/// recomputed from (tasks, _query, _filter) on every build, so there is
/// no second list to keep in sync.
class TaskListScreen extends StatefulWidget {
  final TeamMember currentUser;
  final List<Task> tasks;
  final List<TeamMember> members;
  final void Function(Task) onSaveTask;
  final void Function(String taskId) onDeleteTask;

  const TaskListScreen({
    super.key,
    required this.currentUser,
    required this.tasks,
    required this.members,
    required this.onSaveTask,
    required this.onDeleteTask,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  SlaStatus? _filter; // null = All

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Task> get _visible {
    final q = _query.trim().toLowerCase();
    final list = widget.tasks.where((t) {
      if (_filter != null && SlaService.statusOf(t) != _filter) return false;
      if (q.isEmpty) return true;
      final assignee = findMember(widget.members, t.assigneeId)?.name ?? '';
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          assignee.toLowerCase().contains(q);
    }).toList();

    // Open tasks first by nearest deadline; completed tasks last.
    list.sort((a, b) {
      final aDone = a.status == TaskStatus.done ? 1 : 0;
      final bDone = b.status == TaskStatus.done ? 1 : 0;
      if (aDone != bDone) return aDone - bDone;
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  void _details(Task t) => openTaskDetails(
        context,
        task: t,
        members: widget.members,
        currentUser: widget.currentUser,
        onSaveTask: widget.onSaveTask,
        onDeleteTask: widget.onDeleteTask,
      );

  @override
  Widget build(BuildContext context) {
    final tasks = _visible;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openTaskForm(
          context,
          members: widget.members,
          currentUser: widget.currentUser,
          onSaveTask: widget.onSaveTask,
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _chip('All', null),
                for (final s in SlaStatus.values) _chip(s.label, s),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        widget.tasks.isEmpty
                            ? 'No tasks yet. Tap + to create one.'
                            : 'No tasks match your search or filter.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, 96),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final t = tasks[i];
                      return TaskCard(
                        task: t,
                        assignee: findMember(widget.members, t.assigneeId),
                        onTap: () => _details(t),
                        onEdit: () => openTaskForm(
                          context,
                          task: t,
                          members: widget.members,
                          currentUser: widget.currentUser,
                          onSaveTask: widget.onSaveTask,
                        ),
                        onDelete: () =>
                            confirmDeleteTask(context, t, widget.onDeleteTask),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, SlaStatus? status) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.blue,
        backgroundColor: Colors.white,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.navy,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => setState(() => _filter = status),
      ),
    );
  }
}
