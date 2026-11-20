import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_app/features/course/domain/entities/course.dart';
import 'package:course_app/features/course/domain/entities/instructor.dart';
import 'package:course_app/features/course/domain/entities/lesson.dart';
import 'package:course_app/features/course/domain/repositories/course_repository.dart';
import 'package:course_app/features/course/data/repositories/course_repository_impl.dart';
import 'package:course_app/features/course/presentation/screens/course_list_screen.dart';
import 'package:course_app/features/course/presentation/screens/course_detail_screen.dart';
import 'package:course_app/features/video_player/presentation/screens/lesson_player_screen.dart';
import 'package:course_app/routing/app_router.dart';
import 'package:course_app/main.dart';

class FakeRouterRepository implements CourseRepository {
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
    lessonsCount: 1,
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
    ],
  );

  @override
  Future<List<Course>> getCourses() async => [dummyCourse];

  @override
  Future<Course> getCourseById(String id) async => dummyCourse;

  @override
  Future<Lesson> getLessonById(String courseId, String lessonId) async =>
      dummyCourse.lessons.first;
}

void main() {
  group('AppRouter', () {
    testWidgets('initial route redirects to /courses and renders CourseListScreen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(FakeRouterRepository()),
          ],
          child: const CourseApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseListScreen), findsOneWidget);
    });

    testWidgets('navigating to /courses/c1 renders CourseDetailScreen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(FakeRouterRepository()),
          ],
          child: const CourseApp(),
        ),
      );
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseApp)),
      );
      container.read(routerProvider).go('/courses/c1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseDetailScreen), findsOneWidget);
    });

    testWidgets('navigating to /courses/c1/lessons/l1 renders LessonPlayerScreen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(FakeRouterRepository()),
          ],
          child: const CourseApp(),
        ),
      );
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseApp)),
      );
      container.read(routerProvider).go('/courses/c1/lessons/l1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LessonPlayerScreen), findsOneWidget);
    });
  });
}
