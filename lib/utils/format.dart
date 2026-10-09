class Format {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// e.g. "9 Oct 2026"
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// e.g. "9 Oct 2026, 14:05"
  static String dateTime(DateTime d) =>
      '${date(d)}, ${_two(d.hour)}:${_two(d.minute)}';

  /// e.g. "2 hours ago" / "in 3 days"
  static String timeAgo(DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    final future = diff.isNegative;
    final abs = diff.abs();

    String unit(int n, String word) => '$n $word${n == 1 ? '' : 's'}';

    String text;
    if (abs.inMinutes < 1) {
      return 'just now';
    } else if (abs.inMinutes < 60) {
      text = unit(abs.inMinutes, 'minute');
    } else if (abs.inHours < 24) {
      text = unit(abs.inHours, 'hour');
    } else if (abs.inDays < 30) {
      text = unit(abs.inDays, 'day');
    } else if (abs.inDays < 365) {
      text = unit(abs.inDays ~/ 30, 'month');
    } else {
      text = unit(abs.inDays ~/ 365, 'year');
    }
    return future ? 'in $text' : '$text ago';
  }

  static bool isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
}