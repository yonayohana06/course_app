import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.order,
    required super.title,
    required super.duration,
    required super.durationSeconds,
    required super.videoUrl,
    required super.summary,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String? ?? '',
      courseId: json['course_id'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String? ?? '00:00',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      videoUrl: json['video_url'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'order': order,
      'title': title,
      'duration': duration,
      'duration_seconds': durationSeconds,
      'video_url': videoUrl,
      'summary': summary,
    };
  }
}
