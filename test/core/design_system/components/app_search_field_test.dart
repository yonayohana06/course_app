import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_app/core/design_system/design_system.dart';

void main() {
  group('AppSearchField Widget Tests', () {
    testWidgets('renders hint text and search icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              hintText: 'Cari materi...',
            ),
          ),
        ),
      );

      expect(find.text('Cari materi...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byKey(const Key('app_search_field_clear')), findsNothing);
    });

    testWidgets('calls onChanged and shows clear button when text is entered',
        (tester) async {
      String changedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              onChanged: (val) {
                changedText = val;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('app_search_field_input')),
        'Flutter Riverpod',
      );
      await tester.pump();

      expect(changedText, 'Flutter Riverpod');
      expect(find.byKey(const Key('app_search_field_clear')), findsOneWidget);
    });

    testWidgets('tapping clear button clears text and calls onClear callback',
        (tester) async {
      bool clearTriggered = false;
      String currentText = 'Initial';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              onChanged: (val) => currentText = val,
              onClear: () => clearTriggered = true,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('app_search_field_input')),
        'Initial',
      );
      await tester.pump();

      expect(find.byKey(const Key('app_search_field_clear')), findsOneWidget);

      await tester.tap(find.byKey(const Key('app_search_field_clear')));
      await tester.pump();

      expect(clearTriggered, isTrue);
      expect(currentText, '');
      expect(find.byKey(const Key('app_search_field_clear')), findsNothing);
    });
  });
}
