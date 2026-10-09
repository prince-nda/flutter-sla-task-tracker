import 'package:flutter_test/flutter_test.dart';
import 'package:sla_task_tracker/models/task.dart';
import 'package:sla_task_tracker/services/sla_service.dart';

Task makeTask({
  required DateTime due,
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.todo,
}) =>
    Task(
      id: 't1',
      title: 'Test',
      assigneeId: 'm1',
      dueDate: due,
      priority: priority,
      status: status,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  final now = DateTime(2026, 10, 5, 12, 0);

  test('done task is Completed even if past deadline', () {
    final t = makeTask(due: DateTime(2026, 10, 1), status: TaskStatus.done);
    expect(SlaService.statusOf(t, now: now), SlaStatus.completed);
  });

  test('past deadline and not done is Overdue', () {
    final t = makeTask(due: DateTime(2026, 10, 4));
    expect(SlaService.statusOf(t, now: now), SlaStatus.overdue);
  });

  test('due today (end of day) is not Overdue yet', () {
    final t = makeTask(due: DateTime(2026, 10, 5));
    expect(SlaService.statusOf(t, now: now), SlaStatus.atRisk);
  });

  test('medium priority due in ~2 days is At Risk', () {
    final t = makeTask(due: DateTime(2026, 10, 7));
    expect(SlaService.statusOf(t, now: now), SlaStatus.atRisk);
  });

  test('medium priority due in 5 days is On Track', () {
    final t = makeTask(due: DateTime(2026, 10, 10));
    expect(SlaService.statusOf(t, now: now), SlaStatus.onTrack);
  });

  test('high priority gets a wider At Risk window than low', () {
    final due = DateTime(2026, 10, 8); // ~3.5 days away
    final high = makeTask(due: due, priority: TaskPriority.high);
    final low = makeTask(due: due, priority: TaskPriority.low);
    expect(SlaService.statusOf(high, now: DateTime(2026, 10, 5, 23)),
        SlaStatus.atRisk);
    expect(SlaService.statusOf(low, now: DateTime(2026, 10, 5, 23)),
        SlaStatus.onTrack);
  });

  test('progress is share of done tasks', () {
    final tasks = [
      makeTask(due: DateTime(2026, 10, 9), status: TaskStatus.done),
      makeTask(due: DateTime(2026, 10, 9)),
    ];
    expect(SlaService.progress(tasks), 0.5);
  });
}