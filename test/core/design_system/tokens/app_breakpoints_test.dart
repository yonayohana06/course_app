import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_app/core/design_system/design_system.dart';

void main() {
  group('AppBreakpoints Unit Tests', () {
    test('classifies device screen types correctly based on width', () {
      // Mobile / Compact (< 600 dp)
      expect(AppBreakpoints.getDeviceType(360), DeviceScreenType.compact);
      expect(AppBreakpoints.getDeviceType(599), DeviceScreenType.compact);

      // Foldable unfolded / Tablet portrait (600 - 839 dp)
      expect(AppBreakpoints.getDeviceType(600), DeviceScreenType.medium);
      expect(AppBreakpoints.getDeviceType(768), DeviceScreenType.medium);
      expect(AppBreakpoints.getDeviceType(839), DeviceScreenType.medium);

      // Large tablet / Desktop (>= 840 dp)
      expect(AppBreakpoints.getDeviceType(840), DeviceScreenType.expanded);
      expect(AppBreakpoints.getDeviceType(1024), DeviceScreenType.expanded);
      expect(AppBreakpoints.getDeviceType(1440), DeviceScreenType.expanded);
    });

    testWidgets('ResponsiveContext extension returns correct values',
        (tester) async {
      late BuildContext capturedContext;

      // 1. Test Compact screen (phone)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.isCompact, isTrue);
      expect(capturedContext.isMedium, isFalse);
      expect(capturedContext.isExpanded, isFalse);
      expect(capturedContext.isTabletOrFoldable, isFalse);
      expect(capturedContext.courseGridColumns, 1);
      expect(
        capturedContext.responsiveValue(compact: 'phone', medium: 'fold', expanded: 'tablet'),
        'phone',
      );

      // 2. Test Medium screen (foldable unfolded)
      tester.view.physicalSize = const Size(700, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.isCompact, isFalse);
      expect(capturedContext.isMedium, isTrue);
      expect(capturedContext.isExpanded, isFalse);
      expect(capturedContext.isTabletOrFoldable, isTrue);
      expect(capturedContext.courseGridColumns, 2);
      expect(
        capturedContext.responsiveValue(compact: 'phone', medium: 'fold', expanded: 'tablet'),
        'fold',
      );

      // 3. Test Expanded screen (large tablet)
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.isCompact, isFalse);
      expect(capturedContext.isMedium, isFalse);
      expect(capturedContext.isExpanded, isTrue);
      expect(capturedContext.isTabletOrFoldable, isTrue);
      expect(capturedContext.courseGridColumns, 3);
      expect(
        capturedContext.responsiveValue(compact: 'phone', medium: 'fold', expanded: 'tablet'),
        'tablet',
      );
    });
  });
}
