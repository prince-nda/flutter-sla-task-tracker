import '../models/team_member.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// 10 Dec 2026
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "just now", "5 min ago", "2 hours ago", "3 days ago"
String timeAgo(DateTime t, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(t);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
}

/// Null when the member no longer exists (deleted): screens show "Unassigned".
TeamMember? findMember(List<TeamMember> members, String? id) {
  for (final m in members) {
    if (m.id == id) return m;
  }
  return null;
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());
