import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/task_actions.dart';
import '../widgets/doughnut_chart.dart';
import '../widgets/member_avatar.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatelessWidget {
  final TeamMember currentUser;
  final List<Task> tasks;
  final List<TeamMember> members;
  final VoidCallback onOpenTasks;
  final void Function(Task) onSaveTask;
  final void Function(String taskId) onDeleteTask;

  const DashboardScreen({
    super.key,
    required this.currentUser,
    required this.tasks,
    required this.members,
    required this.onOpenTasks,
    required this.onSaveTask,
    required this.onDeleteTask,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final counts = SlaService.summarize(tasks);
    final progress = SlaService.progress(tasks);
    final recent = [...tasks]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatisticsScreen(tasks: tasks, members: members),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openTaskForm(
          context,
          members: members,
          currentUser: currentUser,
          onSaveTask: onSaveTask,
        ),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
        children: [
          Text('$_greeting, ${currentUser.firstName}',
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Here's what's happening with your project.",
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: AppSpacing.md),

          // Summary cards (2 x 2)
          Row(children: [
            Expanded(
                child: _SummaryCard(
                    label: 'Total Tasks',
                    value: tasks.length,
                    icon: Icons.layers_outlined,
                    color: AppColors.blue,
                    onTap: onOpenTasks)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _SummaryCard(
                    label: 'On Track',
                    value: counts[SlaStatus.onTrack]!,
                    icon: AppColors.iconForSla(SlaStatus.onTrack),
                    color: AppColors.onTrack,
                    onTap: onOpenTasks)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(
                child: _SummaryCard(
                    label: 'At Risk',
                    value: counts[SlaStatus.atRisk]!,
                    icon: AppColors.iconForSla(SlaStatus.atRisk),
                    color: AppColors.atRisk,
                    onTap: onOpenTasks)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: _SummaryCard(
                    label: 'Overdue',
                    value: counts[SlaStatus.overdue]!,
                    icon: AppColors.iconForSla(SlaStatus.overdue),
                    color: AppColors.overdue,
                    onTap: onOpenTasks)),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Task overview: doughnut + legend + progress
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
                  const Text('Task Overview',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      DoughnutChart(counts: counts),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          children: [
                            for (final s in SlaStatus.values)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs),
                                child: Row(children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        color: AppColors.forSla(s),
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: Text(s.label)),
                                  Text('${counts[s]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Overall progress'),
                      Text('${(progress * 100).round()}% done',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.mist,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Recent activity
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
                  const Text('Recent Activity',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text('No activity yet. Create your first task!'),
                    ),
                  for (final t in recent.take(3))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: MemberAvatar(
                          member: findMember(members, t.updatedBy)),
                      title: Text(
                        '${findMember(members, t.updatedBy)?.firstName ?? 'Someone'} updated ${t.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(timeAgo(t.updatedAt)),
                      onTap: () => openTaskDetails(
                        context,
                        task: t,
                        members: members,
                        currentUser: currentUser,
                        onSaveTask: onSaveTask,
                        onDeleteTask: onDeleteTask,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(36),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text('$value',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}