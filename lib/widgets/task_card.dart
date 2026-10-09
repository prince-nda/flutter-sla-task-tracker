import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'member_avatar.dart';
import 'sla_badge.dart';

/// One task row in the Task List.
class TaskCard extends StatelessWidget {
  final Task task;
  final TeamMember? assignee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.assignee,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.statusOf(task);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberAvatar(member: assignee, radius: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assignee?.name ?? 'Unassigned',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.calendar_today_outlined, size: 14),
                          const SizedBox(width: 4),
                          Text(formatDate(task.dueDate),
                              style: const TextStyle(fontSize: 13)),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.flag_outlined,
                              size: 14, color: _priorityColor(task.priority)),
                          const SizedBox(width: 4),
                          Text(task.priority.label,
                              style: const TextStyle(fontSize: 13)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SlaBadge(status: sla),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _priorityColor(TaskPriority p) => switch (p) {
      TaskPriority.high => AppColors.overdue,
      TaskPriority.medium => AppColors.atRisk,
      TaskPriority.low => AppColors.onTrack,
    };