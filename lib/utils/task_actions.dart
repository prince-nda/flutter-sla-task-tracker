import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../screens/create_edit_task_screen.dart';
import '../screens/task_details_screen.dart';

class TaskActions {
  /// Opens the create/edit form. Pass [task] to edit, omit to create.
  /// Returns the saved Task, or null if the user cancelled.
  static Future<Task?> openForm(
    BuildContext context, {
    Task? task,
    required List<TeamMember> members,
  }) {
    return Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (_) => CreateEditTaskScreen(task: task, members: members),
      ),
    );
  }

  /// Opens the details screen. The screen reports changes through callbacks
  /// so app_root.dart (which owns the data) can update its state.
  static Future<void> openDetails(
    BuildContext context, {
    required Task task,
    required List<TeamMember> members,
    required ValueChanged<Task> onUpdate,
    required ValueChanged<String> onDelete,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          task: task,
          members: members,
          onUpdate: onUpdate,
          onDelete: onDelete,
        ),
      ),
    );
  }

  /// Shows a confirmation dialog. Returns true if the user confirmed.
  static Future<bool> confirmDelete(BuildContext context, Task task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}