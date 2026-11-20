import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_app/main.dart';

void main() {
  testWidgets('CourseApp boots and renders app bar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CourseApp(),
      ),
    );
    await tester.pump();

    expect(find.text('E-Learning Platform'), findsOneWidget);
  });
}
