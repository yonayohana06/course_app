import '../../domain/entities/course.dart';
import 'instructor_model.dart';
import 'lesson_model.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.tagline,
    required super.description,
    required super.instructor,
    required super.thumbnailUrl,
    required super.category,
    required super.level,
    required super.totalDuration,
    required super.rating,
    required super.lessonsCount,
    required super.lessons,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List<dynamic>? ?? [];
    final lessons = lessonsJson
        .map((item) => LessonModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CourseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructor: InstructorModel.fromJson(
        (json['instructor'] as Map<String, dynamic>?) ?? {},
      ),
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: json['level'] as String? ?? '',
      totalDuration: json['total_duration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      lessonsCount: (json['lessons_count'] as num?)?.toInt() ?? lessons.length,
      lessons: lessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tagline': tagline,
      'description': description,
      'instructor': (instructor as InstructorModel).toJson(),
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'level': level,
      'total_duration': totalDuration,
      'rating': rating,
      'lessons_count': lessonsCount,
      'lessons': lessons
          .map((l) => (l as LessonModel).toJson())
          .toList(),
    };
  }
}
