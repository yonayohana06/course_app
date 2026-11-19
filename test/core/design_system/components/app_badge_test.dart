import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_app/core/design_system/design_system.dart';

void main() {
  group('AppBadge Widget Tests', () {
    testWidgets('renders basic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(label: 'Badge Test'),
          ),
        ),
      );

      expect(find.text('Badge Test'), findsOneWidget);
    });

    testWidgets('AppBadge.category handles tap and renders label',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBadge.category(
              label: 'Mobile Development',
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Mobile Development'), findsOneWidget);
      await tester.tap(find.text('Mobile Development'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('AppBadge.rating renders rating score and star icon',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBadge.rating(
              rating: 4.9,
              reviewCount: 42,
            ),
          ),
        ),
      );

      expect(find.text('4.9 (42)'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('AppBadge.level renders difficulty level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppBadge.level(level: 'Pemula'),
                AppBadge.level(level: 'Menengah'),
                AppBadge.level(level: 'Mahir'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Pemula'), findsOneWidget);
      expect(find.text('Menengah'), findsOneWidget);
      expect(find.text('Mahir'), findsOneWidget);
    });
  });
}
