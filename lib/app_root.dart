import 'package:flutter/material.dart';

import 'models/task.dart';
import 'models/team_member.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'services/storage_service.dart';

/// Owns ALL app data (tasks, members, signed-in user) with setState().
/// Every change follows the same pattern:
///   1. update the in-memory list inside setState() -> UI rebuilds
///   2. save to local storage -> data survives restart
/// Child screens receive data and callbacks through their constructors.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _storage = StorageService();

  bool _loading = true;
  List<Task> _tasks = [];
  List<TeamMember> _members = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final tasks = await _storage.loadTasks();
    final members = await _storage.loadMembers();
    final userId = await _storage.loadCurrentUserId();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _members = members;
      // Ignore a saved user that no longer exists.
      _currentUserId = members.any((m) => m.id == userId) ? userId : null;
      _loading = false;
    });
  }

  TeamMember? get _currentUser {
    for (final m in _members) {
      if (m.id == _currentUserId) return m;
    }
    return null;
  }

  // ---------- Session ----------

  void _signInAs(String memberId) {
    setState(() => _currentUserId = memberId);
    _storage.saveCurrentUserId(memberId);
  }

  /// Returns an error message, or null on success.
  String? _signInWithEmail(String email, String password) {
    final wanted = email.trim().toLowerCase();
    for (final m in _members) {
      if (m.email.toLowerCase() == wanted) {
        if (m.password == password) {
          _signInAs(m.id);
          return null;
        }
        return 'Incorrect password';
      }
    }
    return 'No account found for this email';
  }

  /// Returns an error message, or null on success.
  String? _signUp(TeamMember member) {
    final taken = _members
        .any((m) => m.email.toLowerCase() == member.email.toLowerCase());
    if (taken) return 'An account with this email already exists';
    _saveMember(member);
    _signInAs(member.id);
    return null;
  }

  void _signOut() {
    setState(() => _currentUserId = null);
    _storage.saveCurrentUserId(null);
  }

  // ---------- Tasks (create = add, edit = replace by id) ----------

  void _saveTask(Task task) {
    setState(() {
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i == -1) {
        _tasks = [..._tasks, task];
      } else {
        _tasks = [..._tasks]..[i] = task;
      }
    });
    _storage.saveTasks(_tasks);
  }

  void _deleteTask(String taskId) {
    setState(() => _tasks = _tasks.where((t) => t.id != taskId).toList());
    _storage.saveTasks(_tasks);
  }

  void _clearTasks() {
    setState(() => _tasks = []);
    _storage.saveTasks(_tasks);
  }

  // ---------- Members ----------

  void _saveMember(TeamMember member) {
    setState(() {
      final i = _members.indexWhere((m) => m.id == member.id);
      if (i == -1) {
        _members = [..._members, member];
      } else {
        _members = [..._members]..[i] = member;
      }
    });
    _storage.saveMembers(_members);
  }

  /// Tasks keep the removed member's id; screens show them as "Unassigned".
  void _deleteMember(String memberId) {
    setState(() => _members = _members.where((m) => m.id != memberId).toList());
    _storage.saveMembers(_members);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _currentUser;
    if (user == null) {
      return SignInScreen(
        members: _members,
        onSignIn: _signInWithEmail,
        onSignUp: _signUp,
        onQuickSelect: _signInAs,
      );
    }

    return HomeShell(
      currentUser: user,
      tasks: _tasks,
      members: _members,
      onSaveTask: _saveTask,
      onDeleteTask: _deleteTask,
      onClearTasks: _clearTasks,
      onSaveMember: _saveMember,
      onDeleteMember: _deleteMember,
      onSignOut: _signOut,
    );
  }
}
