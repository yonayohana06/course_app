import 'instructor.dart';
import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final Instructor instructor;
  final String thumbnailUrl;
  final String category;
  final String level;
  final String totalDuration;
  final double rating;
  final int lessonsCount;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.instructor,
    required this.thumbnailUrl,
    required this.category,
    required this.level,
    required this.totalDuration,
    required this.rating,
    required this.lessonsCount,
    required this.lessons,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
