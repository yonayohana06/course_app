class Instructor {
  final String name;
  final String role;
  final String avatarUrl;

  const Instructor({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Instructor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          role == other.role &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => name.hashCode ^ role.hashCode ^ avatarUrl.hashCode;
}
