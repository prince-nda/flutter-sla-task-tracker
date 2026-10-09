import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../widgets/member_avatar.dart';
import '../widgets/member_form_dialog.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final TeamMember currentUser;
  final List<Task> tasks;
  final List<TeamMember> members;
  final void Function(TeamMember) onSaveMember;
  final VoidCallback onClearTasks;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.tasks,
    required this.members,
    required this.onSaveMember,
    required this.onClearTasks,
    required this.onSignOut,
  });

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.overdue)),
          ),
        ],
      ),
    );
    if (ok == true) onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final mine = tasks.where((t) => t.assigneeId == currentUser.id).toList();
    final counts = SlaService.summarize(mine);
    final open = mine.length - counts[SlaStatus.completed]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              MemberAvatar(member: currentUser, radius: 44),
              const SizedBox(height: AppSpacing.md),
              Text(currentUser.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(currentUser.role,
                  style: const TextStyle(color: Colors.black54)),
              if (currentUser.email.isNotEmpty)
                Text(currentUser.email,
                    style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(child: _stat('My Open Tasks', open, AppColors.blue)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _stat('Completed', counts[SlaStatus.completed]!,
                    AppColors.completed)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _stat(
                    'Overdue', counts[SlaStatus.overdue]!, AppColors.overdue)),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final m = await showMemberFormDialog(context,
                        member: currentUser, allMembers: members);
                    if (m != null) onSaveMember(m);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('App Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(onClearTasks: onClearTasks),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Project & SLA Task Tracker',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Built with Flutter. Data is stored on this device.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.overdue),
                  title: const Text('Sign Out',
                      style: TextStyle(color: AppColors.overdue)),
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) => Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withAlpha(36),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text('$value',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
}
