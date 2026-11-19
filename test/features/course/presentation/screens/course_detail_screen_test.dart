import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_app/features/course/domain/entities/course.dart';
import 'package:course_app/features/course/domain/entities/instructor.dart';
import 'package:course_app/features/course/domain/entities/lesson.dart';
import 'package:course_app/features/course/domain/repositories/course_repository.dart';
import 'package:course_app/features/course/data/repositories/mock_course_repository.dart';
import 'package:course_app/features/course/presentation/screens/course_detail_screen.dart';

class FakeCourseDetailRepository implements CourseRepository {
  Course? courseToReturn;
  Exception? errorToThrow;
  Completer<Course>? completer;

  FakeCourseDetailRepository({
    this.courseToReturn,
    this.errorToThrow,
    this.completer,
  });

  @override
  Future<List<Course>> getCourses() async =>
      courseToReturn != null ? [courseToReturn!] : [];

  @override
  Future<Course> getCourseById(String id) async {
    if (completer != null) return completer!.future;
    if (errorToThrow != null) throw errorToThrow!;
    if (courseToReturn != null) return courseToReturn!;
    throw Exception('Course not found');
  }

  @override
  Future<Lesson> getLessonById(String courseId, String lessonId) async =>
      courseToReturn!.lessons.first;
}

void main() {
  const dummyCourse = Course(
    id: 'course-1',
    title: 'Mastering Flutter Architecture',
    tagline: 'Clean code & Riverpod',
    description: 'A deep architectural guide for Flutter devs.',
    instructor: Instructor(
      name: 'Alex Turner',
      role: 'Staff Engineer',
      avatarUrl: '',
    ),
    thumbnailUrl: '',
    category: 'Architecture',
    level: 'Advanced',
    totalDuration: '45 menit',
    rating: 4.9,
    lessonsCount: 2,
    lessons: [
      Lesson(
        id: 'lesson-1',
        courseId: 'course-1',
        order: 1,
        title: 'Architecture Overview',
        duration: '12:00',
        durationSeconds: 720,
        videoUrl: 'https://example.com/v1.mp4',
        summary: 'Overview summary',
      ),
      Lesson(
        id: 'lesson-2',
        courseId: 'course-1',
        order: 2,
        title: 'Riverpod State Management',
        duration: '15:30',
        durationSeconds: 930,
        videoUrl: 'https://example.com/v2.mp4',
        summary: 'Riverpod deep dive',
      ),
    ],
  );

  Widget createWidgetUnderTest(CourseRepository repo, String courseId) {
    return ProviderScope(
      overrides: [
        courseRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: CourseDetailScreen(courseId: courseId),
      ),
    );
  }

  group('CourseDetailScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      final completer = Completer<Course>();
      final repo = FakeCourseDetailRepository(completer: completer);

      await tester.pumpWidget(createWidgetUnderTest(repo, 'course-1'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(dummyCourse);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Mastering Flutter Architecture'), findsOneWidget);
    });

    testWidgets('displays course info, instructor, and all lessons',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeCourseDetailRepository(courseToReturn: dummyCourse);

      await tester.pumpWidget(createWidgetUnderTest(repo, 'course-1'));
      await tester.pumpAndSettle();

      expect(find.text('Mastering Flutter Architecture'), findsOneWidget);
      expect(find.text('Alex Turner'), findsOneWidget);
      expect(find.text('Architecture Overview'), findsOneWidget);
      expect(find.text('Riverpod State Management'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('15:30'), findsOneWidget);
    });

    testWidgets('displays error view when fetching fails', (tester) async {
      final repo = FakeCourseDetailRepository(
        errorToThrow: Exception('Kursus tidak ditemukan'),
      );

      await tester.pumpWidget(createWidgetUnderTest(repo, 'invalid-id'));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Kursus tidak ditemukan'), findsOneWidget);
    });
  });
}
