import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:course_app/features/course/data/datasources/local_course_data_source.dart';
import 'package:course_app/features/course/data/models/course_model.dart';
import 'package:course_app/features/course/data/models/instructor_model.dart';
import 'package:course_app/features/course/data/models/lesson_model.dart';
import 'package:course_app/features/course/data/repositories/course_repository_impl.dart';

class MockCourseDataSource extends Mock implements CourseDataSource {}

void main() {
  const dummyCourseModel = CourseModel(
    id: 'c1',
    title: 'Flutter Basics',
    tagline: 'Basics',
    description: 'Desc',
    instructor: InstructorModel(name: 'John', role: 'Dev', avatarUrl: ''),
    thumbnailUrl: '',
    category: 'Mobile',
    level: 'Beginner',
    totalDuration: '10 min',
    rating: 5.0,
    lessonsCount: 1,
    lessons: [
      LessonModel(
        id: 'l1',
        courseId: 'c1',
        order: 1,
        title: 'Lesson 1',
        duration: '05:00',
        durationSeconds: 300,
        videoUrl: 'https://example.com/v.mp4',
        summary: 'Summary',
      ),
    ],
  );

  group('CourseRepositoryImpl with MockCourseDataSource (mocktail)', () {
    late MockCourseDataSource mockDataSource;
    late CourseRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockCourseDataSource();
      repository = CourseRepositoryImpl(dataSource: mockDataSource);
      when(() => mockDataSource.getCourses())
          .thenAnswer((_) async => [dummyCourseModel]);
    });

    test('getCourses calls dataSource.getCourses() and returns entities', () async {
      final courses = await repository.getCourses();

      expect(courses.length, 1);
      expect(courses.first.id, 'c1');
      expect(courses.first.title, 'Flutter Basics');
      verify(() => mockDataSource.getCourses()).called(1);
    });

    test('getCourseById returns matching course when found', () async {
      final course = await repository.getCourseById('c1');

      expect(course.id, 'c1');
      expect(course.title, 'Flutter Basics');
      verify(() => mockDataSource.getCourses()).called(1);
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

    test('throws exception when shouldFail is true without calling dataSource', () async {
      final failingRepo = CourseRepositoryImpl(
        dataSource: mockDataSource,
        shouldFail: true,
      );

      expect(
        () => failingRepo.getCourses(),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => mockDataSource.getCourses());
    });
  });

  group('LocalCourseDataSource with custom loader', () {
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

    test('parses json correctly and returns list of CourseModel', () async {
      final dataSource = LocalCourseDataSource(
        customLoader: (_) async => rawJson,
      );
      final courses = await dataSource.getCourses();

      expect(courses.length, 1);
      expect(courses.first.id, 'c1');
      expect(courses.first.title, 'Flutter Basics');
      expect(courses.first.lessons.first.id, 'l1');
    });
  });
}
