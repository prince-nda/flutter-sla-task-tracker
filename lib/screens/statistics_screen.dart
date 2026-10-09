import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/sla_badge.dart';

/// Bar chart built from plain Containers (no chart package): each bar's
/// height is count / maxCount * maxBarHeight.
class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;
  final List<TeamMember> members;
  const StatisticsScreen({super.key, required this.tasks, required this.members});

  @override
  Widget build(BuildContext context) {
    final counts = SlaService.summarize(tasks);
    final maxCount = math.max(1, counts.values.fold<int>(0, math.max));
    const maxBar = 130.0;

    final upcoming = tasks.where((t) => t.status != TaskStatus.done).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final workload = [
      for (final m in members)
        (
          m,
          tasks
              .where((t) => t.assigneeId == m.id && t.status != TaskStatus.done)
              .length
        ),
    ];
    final maxLoad = math.max(1, workload.fold<int>(0, (a, e) => math.max(a, e.$2)));

    return Scaffold(
      appBar: AppBar(title: const Text('Task Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _card(
            title: 'Task Status',
            child: SizedBox(
              height: maxBar + 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final s in SlaStatus.values)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${counts[s]}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 44,
                          height: math.max(4, counts[s]! / maxCount * maxBar),
                          decoration: BoxDecoration(
                            color: AppColors.forSla(s),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(s.label, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _card(
            title: 'Upcoming Deadlines',
            child: upcoming.isEmpty
                ? const Text('No open tasks. Nice work!')
                : Column(
                    children: [
                      for (final t in upcoming.take(5))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_outlined),
                          title: Text(t.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(formatDate(t.dueDate)),
                          trailing: SlaBadge(status: SlaService.statusOf(t)),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _card(
            title: 'Team Workload (open tasks)',
            child: Column(
              children: [
                for (final (m, n) in workload)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      SizedBox(
                        width: 90,
                        child: Text(m.firstName,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: n / maxLoad,
                            minHeight: 12,
                            backgroundColor: AppColors.mist,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('$n',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) => Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      );
}