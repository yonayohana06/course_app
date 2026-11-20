import 'package:material_ui/material_ui.dart';
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
import 'package:course_app/features/video_player/presentation/widgets/lesson_playlist_panel.dart';

class FakeResponsiveRepository implements CourseRepository {
  static const dummyCourse = Course(
    id: 'c1',
    title: 'Flutter Responsive Design',
    tagline: 'Adaptive UI for Foldables & Tablets',
    description: 'Master adaptive layouts in Flutter',
    instructor: Instructor(name: 'Dev Specialist', role: 'Architect', avatarUrl: ''),
    thumbnailUrl: '',
    category: 'Mobile Development',
    level: 'Advanced',
    totalDuration: '30 min',
    rating: 5.0,
    lessonsCount: 2,
    lessons: [
      Lesson(
        id: 'l1',
        courseId: 'c1',
        order: 1,
        title: 'Breakpoints & Layouts',
        duration: '10:00',
        durationSeconds: 600,
        videoUrl: 'https://example.com/v1.mp4',
        summary: 'Overview of layout grids.',
      ),
      Lesson(
        id: 'l2',
        courseId: 'c1',
        order: 2,
        title: 'Split View Architecture',
        duration: '20:00',
        durationSeconds: 1200,
        videoUrl: 'https://example.com/v2.mp4',
        summary: 'Implementing two-column views.',
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
  Widget createScope(Widget child) {
    return ProviderScope(
      overrides: [
        courseRepositoryProvider.overrideWithValue(FakeResponsiveRepository()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Responsive Layout Widget Tests (Phone vs Tablet / Foldable)', () {
    testWidgets('CourseListScreen renders GridView on tablet / foldable width',
        (tester) async {
      // Simulate tablet / foldable unfolded: 800 x 600 dp (1.0 ratio)
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createScope(const CourseListScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      // On tablet width (>= 600 dp), GridView should be used
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Flutter Responsive Design'), findsOneWidget);
    });

    testWidgets('CourseDetailScreen renders split view on tablet landscape (900x700)',
        (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createScope(const CourseDetailScreen(courseId: 'c1')));
      await tester.pump();
      await tester.pumpAndSettle();

      // Header and lessons list both visible in two-column split layout
      expect(find.text('Flutter Responsive Design'), findsOneWidget);
      expect(find.text('Daftar Materi (Lessons)'), findsOneWidget);
      expect(find.text('Breakpoints & Layouts'), findsOneWidget);
      // In split view, CustomScrollView is not used; Row with 2 SingleChildScrollViews is used
      expect(find.byType(CustomScrollView), findsNothing);
    });

    testWidgets(
        'iPad Air 11-inch Portrait (820x1180): CourseDetailScreen renders single column top-aligned',
        (tester) async {
      tester.view.physicalSize = const Size(820, 1180);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createScope(const CourseDetailScreen(courseId: 'c1')));
      await tester.pump();
      await tester.pumpAndSettle();

      // In portrait, uses single-column CustomScrollView constrained to top
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.text('Flutter Responsive Design'), findsOneWidget);
      expect(find.text('Daftar Materi (Lessons)'), findsOneWidget);
    });

    testWidgets(
        'iPad Air 11-inch Landscape (1180x820): CourseDetailScreen renders split view',
        (tester) async {
      tester.view.physicalSize = const Size(1180, 820);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createScope(const CourseDetailScreen(courseId: 'c1')));
      await tester.pump();
      await tester.pumpAndSettle();

      // In landscape, uses split view (no CustomScrollView)
      expect(find.byType(CustomScrollView), findsNothing);
      expect(find.text('Flutter Responsive Design'), findsOneWidget);
      expect(find.text('Daftar Materi (Lessons)'), findsOneWidget);
    });

    testWidgets(
        'iPad Air 11-inch Portrait (820x1180): LessonPlayerScreen uses compact layout without sidebar',
        (tester) async {
      tester.view.physicalSize = const Size(820, 1180);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createScope(const LessonPlayerScreen(courseId: 'c1', lessonId: 'l1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Sidebar playlist panel should NOT be visible in portrait
      expect(find.byType(LessonPlaylistPanel), findsNothing);
      // Playlist icon in AppBar should be visible
      expect(find.byIcon(Icons.playlist_play_rounded), findsOneWidget);
    });

    testWidgets(
        'iPad Air 11-inch Landscape (1180x820): LessonPlayerScreen embeds LessonPlaylistPanel',
        (tester) async {
      tester.view.physicalSize = const Size(1180, 820);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createScope(const LessonPlayerScreen(courseId: 'c1', lessonId: 'l1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Sidebar playlist panel should be visible in landscape
      expect(find.byType(LessonPlaylistPanel), findsOneWidget);
      // Playlist icon in AppBar is not needed when sidebar is present
      expect(find.byIcon(Icons.playlist_play_rounded), findsNothing);
    });

    testWidgets(
        'iPhone 15 Landscape (852x393): LessonPlayerScreen uses compact split layout with SafeArea',
        (tester) async {
      tester.view.physicalSize = const Size(852, 393);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createScope(const LessonPlayerScreen(courseId: 'c1', lessonId: 'l1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Uses split view (embedded LessonPlaylistPanel on the right)
      expect(find.byType(LessonPlaylistPanel), findsOneWidget);
      // Wrapped in SafeArea to avoid Dynamic Island cutouts
      expect(find.byType(SafeArea), findsWidgets);
      // Playlist active badge 'Diputar' and lesson titles are rendered cleanly
      expect(find.text('Breakpoints & Layouts'), findsWidgets);
      expect(find.text('Diputar'), findsOneWidget);
    });

    testWidgets(
        'iPhone 15 Landscape (852x393): CourseListScreen uses 2 columns to prevent cramped cards',
        (tester) async {
      tester.view.physicalSize = const Size(852, 393);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createScope(const CourseListScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      // Uses GridView with 2 columns
      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);
      final GridView gridView = tester.widget(gridViewFinder);
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
    });
  });
}
