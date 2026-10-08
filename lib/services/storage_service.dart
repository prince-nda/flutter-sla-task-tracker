import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/team_member.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _membersKey = 'members';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<List<TeamMember>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_membersKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMembers(List<TeamMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _membersKey, jsonEncode(members.map((m) => m.toJson()).toList()));
  }
}