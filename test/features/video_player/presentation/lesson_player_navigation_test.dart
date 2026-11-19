import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:course_app/features/course/domain/entities/course.dart';
import 'package:course_app/features/course/domain/entities/instructor.dart';
import 'package:course_app/features/course/domain/entities/lesson.dart';
import 'package:course_app/features/course/domain/repositories/course_repository.dart';
import 'package:course_app/features/course/data/repositories/mock_course_repository.dart';
import 'package:course_app/features/video_player/presentation/screens/lesson_player_screen.dart';

class TestNavRepository implements CourseRepository {
  static const dummyCourse = Course(
    id: 'c1',
    title: 'Flutter Architecture',
    tagline: 'Deep dive',
    description: 'Learn architecture',
    instructor: Instructor(name: 'Dev', role: 'Lead', avatarUrl: ''),
    thumbnailUrl: '',
    category: 'Mobile Development',
    level: 'Advanced',
    totalDuration: '20 min',
    rating: 5.0,
    lessonsCount: 2,
    lessons: [
      Lesson(
        id: 'l1',
        courseId: 'c1',
        order: 1,
        title: 'Lesson 1',
        duration: '10:00',
        durationSeconds: 600,
        videoUrl: 'https://example.com/v1.mp4',
        summary: 'Intro',
      ),
      Lesson(
        id: 'l2',
        courseId: 'c1',
        order: 2,
        title: 'Lesson 2',
        duration: '12:00',
        durationSeconds: 720,
        videoUrl: 'https://example.com/v2.mp4',
        summary: 'Deep dive',
      ),
    ],
  );

  @override
  Future<List<Course>> getCourses() async => [dummyCourse];

  @override
  Future<Course> getCourseById(String id) async => dummyCourse;

  @override
  Future<Lesson> getLessonById(String courseId, String lessonId) async =>
      dummyCourse.lessons.firstWhere((l) => l.id == lessonId);
}

void main() {
  testWidgets('clicking Berikutnya button navigates to next lesson',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final router = GoRouter(
      initialLocation: '/courses/c1/lessons/l1',
      routes: [
        GoRoute(
          path: '/courses/:courseId/lessons/:lessonId',
          builder: (context, state) => LessonPlayerScreen(
            courseId: state.pathParameters['courseId']!,
            lessonId: state.pathParameters['lessonId']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseRepositoryProvider.overrideWithValue(TestNavRepository()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Lesson 1'), findsWidgets);

    // Tap "Berikutnya"
    final nextButton = find.widgetWithText(ElevatedButton, 'Berikutnya');
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Lesson 2'), findsWidgets);
  });
}
