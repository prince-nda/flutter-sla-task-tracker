class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Member',
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  TeamMember copyWith({String? name, String? email, String? role}) =>
      TeamMember(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'email': email, 'role': role};

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: (json['role'] as String?) ?? 'Member',
      );
}