import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_app/features/course/domain/entities/course.dart';
import 'package:course_app/features/course/domain/entities/instructor.dart';
import 'package:course_app/features/course/domain/entities/lesson.dart';
import 'package:course_app/features/course/domain/repositories/course_repository.dart';
import 'package:course_app/features/course/data/repositories/course_repository_impl.dart';
import 'package:course_app/features/video_player/presentation/screens/lesson_player_screen.dart';

class FakePlayerRepo implements CourseRepository {
  final Course course;

  FakePlayerRepo(this.course);

  @override
  Future<List<Course>> getCourses() async => [course];

  @override
  Future<Course> getCourseById(String id) async => course;

  @override
  Future<Lesson> getLessonById(String courseId, String lessonId) async =>
      course.lessons.firstWhere((l) => l.id == lessonId);
}

void main() {
  const dummyCourse = Course(
    id: 'c1',
    title: 'Flutter Architecture',
    tagline: 'Deep dive',
    description: 'Learn architecture',
    instructor: Instructor(name: 'Dev', role: 'Lead', avatarUrl: ''),
    thumbnailUrl: '',
    category: 'Tech',
    level: 'Advanced',
    totalDuration: '20 min',
    rating: 5.0,
    lessonsCount: 2,
    lessons: [
      Lesson(
        id: 'l1',
        courseId: 'c1',
        order: 1,
        title: 'Pengenalan Arsitektur',
        duration: '10:00',
        durationSeconds: 600,
        videoUrl: 'https://example.com/v1.mp4',
        summary: 'Ringkasan pengenalan arsitektur.',
      ),
      Lesson(
        id: 'l2',
        courseId: 'c1',
        order: 2,
        title: 'Materi Lanjutan Riverpod',
        duration: '15:00',
        durationSeconds: 900,
        videoUrl: 'https://example.com/v2.mp4',
        summary: 'Ringkasan lanjutan.',
      ),
    ],
  );

  Widget createWidgetUnderTest(String lessonId) {
    return ProviderScope(
      overrides: [
        courseRepositoryProvider
            .overrideWithValue(FakePlayerRepo(dummyCourse)),
      ],
      child: MaterialApp(
        home: LessonPlayerScreen(courseId: 'c1', lessonId: lessonId),
      ),
    );
  }

  group('LessonPlayerScreen UI', () {
    testWidgets('renders lesson details, order badge, and summary',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('l1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pengenalan Arsitektur'), findsWidgets);
      expect(find.text('Materi #1'), findsOneWidget);
      expect(find.text('Ringkasan pengenalan arsitektur.'), findsOneWidget);
      expect(find.text('Berikutnya'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsOneWidget);
    });

    testWidgets(
        'displays navigation buttons with correct enabled/disabled state on first lesson',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('l1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // For l1 (first lesson):
      // "Sebelumnya" should be disabled because it is the first lesson
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Sebelumnya'),
      );
      expect(prevButton.onPressed, isNull);

      // "Berikutnya" should be enabled because l2 exists
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Berikutnya'),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets(
        'displays navigation buttons with correct enabled/disabled state on second/last lesson',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest('l2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // For l2 (second lesson):
      // "Sebelumnya" should be enabled because l1 exists
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Sebelumnya'),
      );
      expect(prevButton.onPressed, isNotNull);

      // "Berikutnya" should be disabled because l2 is the last lesson
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Berikutnya'),
      );
      expect(nextButton.onPressed, isNull);
    });
  });
}
