import '../models/task.dart';

enum SlaState { completed, overdue, atRisk, onTrack }

class SlaService {
  /// A task is "At Risk" when it is due within this window.
  static const Duration atRiskWindow = Duration(hours: 24);

  static SlaState evaluate(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (task.status == TaskStatus.completed) return SlaState.completed;
    if (current.isAfter(task.dueDate)) return SlaState.overdue;
    if (task.dueDate.difference(current) <= atRiskWindow) {
      return SlaState.atRisk;
    }
    return SlaState.onTrack;
  }

  static String label(SlaState state) {
    switch (state) {
      case SlaState.completed:
        return 'Completed';
      case SlaState.overdue:
        return 'Overdue';
      case SlaState.atRisk:
        return 'At Risk';
      case SlaState.onTrack:
        return 'On Track';
    }
  }

  /// Positive = time left, negative = time past due.
  static Duration timeRemaining(Task task, {DateTime? now}) =>
      task.dueDate.difference(now ?? DateTime.now());

  static Map<SlaState, int> countByState(List<Task> tasks, {DateTime? now}) {
    final counts = {for (final s in SlaState.values) s: 0};
    for (final t in tasks) {
      final s = evaluate(t, now: now);
      counts[s] = counts[s]! + 1;
    }
    return counts;
  }
}