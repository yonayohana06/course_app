import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_app/routing/app_router.dart';
import 'package:course_app/main.dart';

void main() {
  group('AppRouter', () {
    testWidgets('initial route redirects to /courses and renders CourseListScreen',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Course List Screen'), findsOneWidget);
    });

    testWidgets('navigating to /courses/c1 renders CourseDetailScreen',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseApp)),
      );
      container.read(routerProvider).go('/courses/c1');
      await tester.pumpAndSettle();

      expect(find.text('Course Detail: c1'), findsOneWidget);
    });

    testWidgets('navigating to /courses/c1/lessons/l1 renders LessonPlayerScreen',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseApp)),
      );
      container.read(routerProvider).go('/courses/c1/lessons/l1');
      await tester.pumpAndSettle();

      expect(find.text('Player: c1 / l1'), findsOneWidget);
    });
  });
}
