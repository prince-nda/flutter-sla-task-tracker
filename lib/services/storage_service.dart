import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/team_member.dart';

/// Persists data on the device with SharedPreferences (JSON strings).
/// Chosen because the dataset is small (a handful of tasks/members) and
/// needs no queries, so SQLite would add complexity without benefit.
class StorageService {
  static const _tasksKey = 'tasks';
  static const _membersKey = 'members_v2'; // v2: members now have accounts
  static const _currentUserKey = 'current_user_id';

  // TODO: replace with your own group's names before the demo.
  static const List<TeamMember> _defaultMembers = [
    TeamMember(
        id: 'm1',
        name: 'David MUGISHA',
        role: 'Project Manager',
        email: 'd.mugisha1@alustudent.com',
        password: 'password123'),
    TeamMember(
        id: 'm2',
        name: 'Sylivie TUMUKUNDE',
        role: 'UI/UX Designer',
        email: 's.tumukunde@alustudent.com',
        password: 'password123'),
    TeamMember(
        id: 'm3',
        name: 'Prince NDAHIRO',
        role: 'Mobile Developer',
        email: 'p.ndahiro1@alustudent.com',
        password: 'password123'),
    TeamMember(
        id: 'm4',
        name: 'Dedine MUKABUCYANA',
        role: 'QA Tester',
        email: 'd.mukabucya@alustudent.com',
        password: 'password123'),
  ];

  // ---------- Tasks ----------

  /// On the very first launch, seeds sample tasks (relative to today) so the
  /// SLA statuses can be demonstrated immediately. After that, an empty
  /// list stays empty.
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) {
      final seeded = _sampleTasks(DateTime.now());
      await saveTasks(seeded);
      return seeded;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt or outdated data: start clean instead of crashing.
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  List<Task> _sampleTasks(DateTime now) {
    DateTime due(int days) => DateTime(now.year, now.month, now.day + days);
    DateTime ago(Duration d) => now.subtract(d);
    return [
      Task(
        id: 't1',
        title: 'Design sign-in screen',
        description: 'Build the sign-in and sign-up screens with validation.',
        assigneeId: 'm2',
        dueDate: due(5),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        createdAt: ago(const Duration(days: 4)),
        updatedAt: ago(const Duration(hours: 2)),
        updatedBy: 'm2',
      ),
      Task(
        id: 't2',
        title: 'Implement local storage',
        description: 'Save tasks and members with SharedPreferences.',
        assigneeId: 'm3',
        dueDate: due(1),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        createdAt: ago(const Duration(days: 5)),
        updatedAt: ago(const Duration(hours: 5)),
        updatedBy: 'm3',
      ),
      Task(
        id: 't3',
        title: 'Create task model',
        description: 'Task class with JSON conversion.',
        assigneeId: 'm3',
        dueDate: due(-2),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        createdAt: ago(const Duration(days: 8)),
        updatedAt: ago(const Duration(days: 1)),
        updatedBy: 'm3',
      ),
      Task(
        id: 't4',
        title: 'Write SLA unit tests',
        description: 'Cover every SLA state and priority window.',
        assigneeId: 'm4',
        dueDate: due(9),
        priority: TaskPriority.low,
        createdAt: ago(const Duration(days: 2)),
        updatedBy: 'm1',
      ),
      Task(
        id: 't5',
        title: 'Record demo video',
        description: 'Every member explains their own part.',
        assigneeId: 'm1',
        dueDate: due(14),
        priority: TaskPriority.medium,
        createdAt: ago(const Duration(days: 1)),
        updatedBy: 'm1',
      ),
      Task(
        id: 't6',
        title: 'Draft technical report',
        description: 'Challenges faced and how we solved them.',
        assigneeId: 'm1',
        dueDate: due(-5),
        priority: TaskPriority.medium,
        status: TaskStatus.done,
        createdAt: ago(const Duration(days: 10)),
        updatedAt: ago(const Duration(days: 3)),
        updatedBy: 'm1',
      ),
    ];
  }

  // ---------- Team members ----------

  /// Returns saved members, or seeds the default team on first launch.
  Future<List<TeamMember>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_membersKey);
    if (raw == null) {
      await saveMembers(_defaultMembers);
      return List.of(_defaultMembers);
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List.of(_defaultMembers);
    }
  }

  Future<void> saveMembers(List<TeamMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _membersKey,
      jsonEncode(members.map((m) => m.toJson()).toList()),
    );
  }

  // ---------- Signed-in user ----------

  Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> saveCurrentUserId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, id);
    }
  }
}
