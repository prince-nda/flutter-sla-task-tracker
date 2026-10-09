import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onClearTasks;
  const SettingsScreen({super.key, required this.onClearTasks});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all tasks?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete all',
                style: TextStyle(color: AppColors.overdue)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    onClearTasks();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('All tasks deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How SLA status works',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Completed: the task status is Done.'),
                  const Text(
                      'Overdue: not done and the due date has passed (the deadline is the end of the due day).'),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                      'At Risk: not done and the time left is inside the window for its priority:'),
                  for (final e in SlaService.atRiskWindow.entries)
                    Text('   • ${e.key.label}: ${e.value.inHours} hours'),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('On Track: everything else.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.storage_outlined),
                  title: Text('Storage'),
                  subtitle: Text('Saved on this device with SharedPreferences'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: AppColors.overdue),
                  title: const Text('Delete all tasks',
                      style: TextStyle(color: AppColors.overdue)),
                  onTap: () => _confirmClear(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
