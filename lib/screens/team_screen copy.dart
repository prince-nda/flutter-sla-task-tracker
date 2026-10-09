import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../theme/app_theme.dart';
import '../widgets/member_avatar.dart';
import '../widgets/member_form_dialog.dart';

class TeamScreen extends StatelessWidget {
  final String currentUserId;
  final List<TeamMember> members;
  final List<Task> tasks;
  final void Function(TeamMember) onSaveMember;
  final void Function(String memberId) onDeleteMember;

  const TeamScreen({
    super.key,
    required this.currentUserId,
    required this.members,
    required this.tasks,
    required this.onSaveMember,
    required this.onDeleteMember,
  });

  int _openTasks(String id) => tasks
      .where((t) => t.assigneeId == id && t.status != TaskStatus.done)
      .length;

  Future<void> _add(BuildContext context) async {
    final m = await showMemberFormDialog(context, allMembers: members);
    if (m == null || !context.mounted) return;
    onSaveMember(m);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text('${m.name} added. Default password: ${TeamMember.defaultPassword}'),
    ));
  }

  Future<void> _edit(BuildContext context, TeamMember member) async {
    final m = await showMemberFormDialog(context,
        member: member, allMembers: members);
    if (m != null) onSaveMember(m);
  }

  Future<void> _remove(BuildContext context, TeamMember member) async {
    if (member.id == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't remove the signed-in user")),
      );
      return;
    }
    final open = _openTasks(member.id);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${member.name}?'),
        content: Text(open == 0
            ? 'This member will be removed from the team.'
            : 'Their $open open task${open == 1 ? '' : 's'} will show as Unassigned.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: AppColors.overdue)),
          ),
        ],
      ),
    );
    if (ok == true) onDeleteMember(member.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            tooltip: 'Add member',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _add(context),
          ),
        ],
      ),
      body: members.isEmpty
          ? const Center(child: Text('No team members yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final m = members[i];
                final open = _openTasks(m.id);
                return Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    leading: MemberAvatar(member: m),
                    title: Row(children: [
                      Flexible(
                        child: Text(m.name,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      if (m.id == currentUserId) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('You',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ]),
                    subtitle: Text('${m.role} · $open open task${open == 1 ? '' : 's'}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => v == 'edit'
                          ? _edit(context, m)
                          : _remove(context, m),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'remove', child: Text('Remove')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
