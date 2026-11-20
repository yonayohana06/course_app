import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:course_app/features/course/domain/entities/course.dart';
import 'package:course_app/features/course/domain/entities/instructor.dart';
import 'package:course_app/features/course/domain/entities/lesson.dart';
import 'package:course_app/features/course/domain/repositories/course_repository.dart';
import 'package:course_app/features/course/data/repositories/course_repository_impl.dart';
import 'package:course_app/features/course/presentation/screens/course_list_screen.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  late MockCourseRepository mockRepository;

  const dummyCourse = Course(
    id: 'c1',
    title: 'Flutter Advanced',
    tagline: 'Deep dive into Flutter',
    description: 'Learn everything about Flutter',
    instructor: Instructor(
      name: 'John Doe',
      role: 'Tech Lead',
      avatarUrl: '',
    ),
    thumbnailUrl: '',
    category: 'Mobile Development',
    level: 'Advanced',
    totalDuration: '2 jam',
    rating: 4.9,
    lessonsCount: 1,
    lessons: [
      Lesson(
        id: 'l1',
        courseId: 'c1',
        order: 1,
        title: 'Introduction',
        duration: '10:00',
        durationSeconds: 600,
        videoUrl: 'https://example.com/v.mp4',
        summary: 'Intro summary',
      ),
    ],
  );

  setUp(() {
    mockRepository = MockCourseRepository();
  });

  Widget createWidgetUnderTest(CourseRepository repo) {
    return ProviderScope(
      overrides: [
        courseRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: CourseListScreen(),
      ),
    );
  }

  group('CourseListScreen UI States with Mocktail', () {
    testWidgets('shows loading indicator while fetching courses',
        (tester) async {
      final completer = Completer<List<Course>>();
      when(() => mockRepository.getCourses()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest(mockRepository));
      await tester.pump(); // Start build

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([dummyCourse]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Flutter Advanced'), findsOneWidget);
      verify(() => mockRepository.getCourses()).called(1);
    });

    testWidgets('shows empty state view when no courses are available',
        (tester) async {
      when(() => mockRepository.getCourses()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kursus tersedia'), findsOneWidget);
      verify(() => mockRepository.getCourses()).called(1);
    });

    testWidgets('shows error state view with retry button on failure',
        (tester) async {
      when(() => mockRepository.getCourses())
          .thenThrow(Exception('Koneksi terputus'));

      await tester.pumpWidget(createWidgetUnderTest(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Fix error and tap retry
      when(() => mockRepository.getCourses())
          .thenAnswer((_) async => [dummyCourse]);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Advanced'), findsOneWidget);
      verify(() => mockRepository.getCourses()).called(greaterThanOrEqualTo(2));
    });
  });
}
