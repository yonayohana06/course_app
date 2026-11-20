import 'package:flutter_test/flutter_test.dart';
import 'package:course_app/features/course/data/models/course_model.dart';
import 'package:course_app/features/course/domain/entities/course.dart';

void main() {
  group('CourseModel', () {
    final mockJson = {
      'id': 'course-1',
      'title': 'Mastering Flutter',
      'tagline': 'Modern state management',
      'description': 'Full description',
      'instructor': {
        'name': 'Budi Santoso',
        'role': 'Senior Mobile Engineer',
        'avatar_url': 'https://example.com/avatar.jpg',
      },
      'thumbnail_url': 'https://example.com/thumb.jpg',
      'category': 'Mobile Development',
      'level': 'Intermediate',
      'total_duration': '45 menit',
      'rating': 4.9,
      'lessons_count': 1,
      'lessons': [
        {
          'id': 'lesson-101',
          'course_id': 'course-1',
          'order': 1,
          'title': 'Intro',
          'duration': '09:56',
          'duration_seconds': 596,
          'video_url': 'https://example.com/video.mp4',
          'summary': 'Summary of intro',
        }
      ],
    };

    test('should parse valid json into CourseModel and inherit Course entity', () {
      final model = CourseModel.fromJson(mockJson);

      expect(model, isA<Course>());
      expect(model.id, 'course-1');
      expect(model.title, 'Mastering Flutter');
      expect(model.instructor.name, 'Budi Santoso');
      expect(model.lessons.length, 1);
      expect(model.lessons.first.videoUrl, 'https://example.com/video.mp4');
    });

    test('should convert CourseModel to valid json map', () {
      final model = CourseModel.fromJson(mockJson);
      final json = model.toJson();

      expect(json['id'], 'course-1');
      expect(json['title'], 'Mastering Flutter');
      expect((json['lessons'] as List).length, 1);
    });
  });
}
