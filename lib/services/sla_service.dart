import '../models/task.dart';

/// All SLA business rules live here so they are easy to explain and test.
///
/// Rules (checked in this order):
///  1. Completed : task status is Done.
///  2. Overdue   : not done and the deadline has passed.
///  3. At Risk   : not done and the time left is within the priority window
///                 (High = 72h, Medium = 48h, Low = 24h).
///  4. On Track  : everything else.
///
/// The due date is a calendar date, so the deadline is the END of that day.
class SlaService {
  static const Map<TaskPriority, Duration> atRiskWindow = {
    TaskPriority.high: Duration(hours: 72),
    TaskPriority.medium: Duration(hours: 48),
    TaskPriority.low: Duration(hours: 24),
  };

  /// 23:59:59 on the task's due date.
  static DateTime deadline(Task task) => DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
        23,
        59,
        59,
      );

  /// [now] is injectable so the rules can be unit tested.
  static SlaStatus statusOf(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (task.status == TaskStatus.done) return SlaStatus.completed;

    final due = deadline(task);
    if (current.isAfter(due)) return SlaStatus.overdue;

    final remaining = due.difference(current);
    if (remaining <= atRiskWindow[task.priority]!) return SlaStatus.atRisk;

    return SlaStatus.onTrack;
  }

  /// Human-readable explanation, e.g. for the "SLA Status" card on Task Details.
  static String explain(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    switch (statusOf(task, now: current)) {
      case SlaStatus.completed:
        return 'This task has been completed.';
      case SlaStatus.overdue:
        final late = current.difference(deadline(task));
        return 'The deadline passed ${_format(late)} ago.';
      case SlaStatus.atRisk:
        final left = deadline(task).difference(current);
        return 'Due in ${_format(left)}. Within the '
            '${atRiskWindow[task.priority]!.inHours}h window for '
            '${task.priority.label} priority.';
      case SlaStatus.onTrack:
        return 'The task is progressing as expected.';
    }
  }

  /// Count of tasks per SLA status (for dashboard cards and charts).
  static Map<SlaStatus, int> summarize(List<Task> tasks, {DateTime? now}) {
    final counts = {for (final s in SlaStatus.values) s: 0};
    for (final t in tasks) {
      final s = statusOf(t, now: now);
      counts[s] = counts[s]! + 1;
    }
    return counts;
  }

  /// Share of tasks that are done, 0.0 to 1.0.
  static double progress(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    return done / tasks.length;
  }

  static String _format(Duration d) {
    if (d.inDays >= 1) return '${d.inDays} day${d.inDays == 1 ? '' : 's'}';
    if (d.inHours >= 1) return '${d.inHours} hour${d.inHours == 1 ? '' : 's'}';
    return '${d.inMinutes.clamp(1, 59)} min';
  }
}
