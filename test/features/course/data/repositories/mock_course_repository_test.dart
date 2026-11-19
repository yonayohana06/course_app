import 'package:flutter_test/flutter_test.dart';
import 'package:course_app/features/course/data/datasources/local_course_data_source.dart';
import 'package:course_app/features/course/data/models/course_model.dart';
import 'package:course_app/features/course/data/repositories/mock_course_repository.dart';

void main() {
  group('MockCourseRepository', () {
    const rawJson = '''
    {
      "status": "success",
      "data": [
        {
          "id": "c1",
          "title": "Flutter Basics",
          "tagline": "Basics",
          "description": "Desc",
          "instructor": {"name": "John", "role": "Dev", "avatar_url": ""},
          "thumbnail_url": "",
          "category": "Mobile",
          "level": "Beginner",
          "total_duration": "10 min",
          "rating": 5.0,
          "lessons_count": 1,
          "lessons": [
            {
              "id": "l1",
              "course_id": "c1",
              "order": 1,
              "title": "Lesson 1",
              "duration": "05:00",
              "duration_seconds": 300,
              "video_url": "https://example.com/v.mp4",
              "summary": "Summary"
            }
          ]
        }
      ]
    }
    ''';

    late LocalCourseDataSource dataSource;
    late MockCourseRepository repository;

    setUp(() {
      dataSource = LocalCourseDataSource(
        customLoader: (_) async => rawJson,
      );
      repository = MockCourseRepository(dataSource: dataSource);
    });

    test('getCourses returns list of Course entities', () async {
      final courses = await repository.getCourses();

      expect(courses.length, 1);
      expect(courses.first.id, 'c1');
      expect(courses.first.title, 'Flutter Basics');
    });

    test('getCourseById returns matching course when found', () async {
      final course = await repository.getCourseById('c1');

      expect(course.id, 'c1');
      expect(course.title, 'Flutter Basics');
    });

    test('getCourseById throws exception when course not found', () async {
      expect(
        () => repository.getCourseById('unknown_id'),
        throwsA(isA<Exception>()),
      );
    });

    test('getLessonById returns matching lesson', () async {
      final lesson = await repository.getLessonById('c1', 'l1');

      expect(lesson.id, 'l1');
      expect(lesson.title, 'Lesson 1');
      expect(lesson.videoUrl, 'https://example.com/v.mp4');
    });

    test('throws exception when shouldFail is true', () async {
      final failingRepo = MockCourseRepository(
        dataSource: dataSource,
        shouldFail: true,
      );

      expect(
        () => failingRepo.getCourses(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
