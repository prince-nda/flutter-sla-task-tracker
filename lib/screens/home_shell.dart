import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'task_list_screen.dart';
import 'team_screen.dart';

/// Main navigation: a bottom NavigationBar switching between 4 tabs.
/// Detail screens (Task Details, Create/Edit Task, Statistics, Settings)
/// are pushed on top with Navigator.push, so back returns to the tab.
class HomeShell extends StatefulWidget {
  final TeamMember currentUser;
  final List<Task> tasks;
  final List<TeamMember> members;
  final void Function(Task) onSaveTask;
  final void Function(String taskId) onDeleteTask;
  final VoidCallback onClearTasks;
  final void Function(TeamMember) onSaveMember;
  final void Function(String memberId) onDeleteMember;
  final VoidCallback onSignOut;

  const HomeShell({
    super.key,
    required this.currentUser,
    required this.tasks,
    required this.members,
    required this.onSaveTask,
    required this.onDeleteTask,
    required this.onClearTasks,
    required this.onSaveMember,
    required this.onDeleteMember,
    required this.onSignOut,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Built here (not in initState) so tabs always get the latest data.
    final pages = <Widget>[
      DashboardScreen(
        currentUser: widget.currentUser,
        tasks: widget.tasks,
        members: widget.members,
        onOpenTasks: () => setState(() => _index = 1),
        onSaveTask: widget.onSaveTask,
        onDeleteTask: widget.onDeleteTask,
      ),
      TaskListScreen(
        currentUser: widget.currentUser,
        tasks: widget.tasks,
        members: widget.members,
        onSaveTask: widget.onSaveTask,
        onDeleteTask: widget.onDeleteTask,
      ),
      TeamScreen(
        currentUserId: widget.currentUser.id,
        members: widget.members,
        tasks: widget.tasks,
        onSaveMember: widget.onSaveMember,
        onDeleteMember: widget.onDeleteMember,
      ),
      ProfileScreen(
        currentUser: widget.currentUser,
        tasks: widget.tasks,
        members: widget.members,
        onSaveMember: widget.onSaveMember,
        onClearTasks: widget.onClearTasks,
        onSignOut: widget.onSignOut,
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
