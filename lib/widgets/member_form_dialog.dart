import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../utils/format.dart';

/// Add/Edit member dialog. Returns the new/updated member, or null if
/// cancelled. Used by the Team screen and by Profile > Edit Profile.
Future<TeamMember?> showMemberFormDialog(
  BuildContext context, {
  TeamMember? member,
  required List<TeamMember> allMembers,
}) {
  return showDialog<TeamMember>(
    context: context,
    builder: (_) => _MemberFormDialog(member: member, allMembers: allMembers),
  );
}

class _MemberFormDialog extends StatefulWidget {
  final TeamMember? member;
  final List<TeamMember> allMembers;
  const _MemberFormDialog({required this.member, required this.allMembers});

  @override
  State<_MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.member?.name);
  late final _roleCtrl = TextEditingController(text: widget.member?.role);
  late final _emailCtrl = TextEditingController(text: widget.member?.email);

  bool get _isEdit => widget.member != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.member;
    final result = existing == null
        ? TeamMember(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: _nameCtrl.text.trim(),
            role: _roleCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: TeamMember.defaultPassword,
          )
        : existing.copyWith(
            name: _nameCtrl.text.trim(),
            role: _roleCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
          );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Member' : 'Add Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Name is required';
                  if (t.length < 2) return 'Name is too short';
                  if (t.length > 40) return 'Name must be 40 characters or less';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Role', hintText: 'e.g. QA Tester'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Role is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Email is required';
                  if (!isValidEmail(t)) return 'Enter a valid email address';
                  final taken = widget.allMembers.any((m) =>
                      m.id != widget.member?.id &&
                      m.email.toLowerCase() == t.toLowerCase());
                  if (taken) return 'This email is already used';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}