import '../../domain/entities/instructor.dart';

class InstructorModel extends Instructor {
  const InstructorModel({
    required super.name,
    required super.role,
    required super.avatarUrl,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}
