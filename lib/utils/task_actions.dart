import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../screens/create_edit_task_screen.dart';
import '../screens/task_details_screen.dart';
import '../theme/app_theme.dart';

/// Opens the Create/Edit form. The form returns the finished Task via
/// Navigator.pop, and we hand it to onSaveTask (which calls setState and
/// saves to storage in AppRoot).
Future<void> openTaskForm(
  BuildContext context, {
  Task? task,
  required List<TeamMember> members,
  required TeamMember currentUser,
  required void Function(Task) onSaveTask,
}) async {
  final result = await Navigator.push<Task>(
    context,
    MaterialPageRoute(
      builder: (_) => CreateEditTaskScreen(
        task: task,
        members: members,
        currentUser: currentUser,
      ),
    ),
  );
  if (result == null || !context.mounted) return;
  onSaveTask(result);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(task == null ? 'Task created' : 'Task updated')),
  );
}

Future<void> openTaskDetails(
  BuildContext context, {
  required Task task,
  required List<TeamMember> members,
  required TeamMember currentUser,
  required void Function(Task) onSaveTask,
  required void Function(String) onDeleteTask,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TaskDetailsScreen(
        task: task,
        members: members,
        currentUser: currentUser,
        onSaveTask: onSaveTask,
        onDeleteTask: onDeleteTask,
      ),
    ),
  );
}

/// Returns true if the task was deleted.
Future<bool> confirmDeleteTask(
  BuildContext context,
  Task task,
  void Function(String) onDelete,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete task?'),
      content: Text('"${task.title}" will be permanently removed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete',
              style: TextStyle(color: AppColors.overdue)),
        ),
      ],
    ),
  );
  if (ok == true) {
    onDelete(task.id);
    return true;
  }
  return false;
}
