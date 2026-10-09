class TeamMember {
  /// Password given to members added from the Team screen.
  static const defaultPassword = 'welcome123';

  final String id;
  final String name;
  final String role;
  final String email;

  /// Local demo accounts only: there is no backend, so this is stored on
  /// the device as plain text. Never do this in a real app.
  final String password;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    this.email = '',
    this.password = '',
  });

  /// "Sarah Lee" -> "SL" (used for avatars).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  TeamMember copyWith({
    String? name,
    String? role,
    String? email,
    String? password,
  }) =>
      TeamMember(
        id: id,
        name: name ?? this.name,
        role: role ?? this.role,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'email': email,
        'password': password,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        email: (json['email'] ?? '') as String,
        password: (json['password'] ?? '') as String,
      );
}
