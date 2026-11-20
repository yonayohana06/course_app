import 'package:material_ui/material_ui.dart';

/// Screen type based on Material 3 responsive layout grid specifications.
enum DeviceScreenType {
  /// Width < 600 dp (smartphones, folded foldable phone cover screen)
  compact,

  /// Width 600 - 839 dp (Samsung Galaxy Fold unfolded, small tablets)
  medium,

  /// Width >= 840 dp (large tablets, iPad Pro, desktop)
  expanded,
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double compactMax = 599.0;
  static const double mediumMin = 600.0;
  static const double mediumMax = 839.0;
  static const double expandedMin = 840.0;

  /// Max content width for wide displays to prevent stretching
  static const double maxContentWidth = 1200.0;

  static DeviceScreenType getDeviceType(double width) {
    if (width < mediumMin) {
      return DeviceScreenType.compact;
    }
    if (width <= mediumMax) {
      return DeviceScreenType.medium;
    }
    return DeviceScreenType.expanded;
  }
}

/// Responsive extensions on [BuildContext] for easy layout adaptation.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  DeviceScreenType get screenType => AppBreakpoints.getDeviceType(screenWidth);

  bool get isCompact => screenWidth < AppBreakpoints.mediumMin;
  bool get isMedium =>
      screenWidth >= AppBreakpoints.mediumMin &&
      screenWidth <= AppBreakpoints.mediumMax;
  bool get isExpanded => screenWidth > AppBreakpoints.mediumMax;
  bool get isTabletOrFoldable => screenWidth >= AppBreakpoints.mediumMin;

  /// Returns responsive value according to current screen breakpoint.
  T responsiveValue<T>({
    required T compact,
    T? medium,
    T? expanded,
  }) {
    if (isExpanded && expanded != null) {
      return expanded;
    }
    if (isMedium && medium != null) {
      return medium;
    }
    if (isTabletOrFoldable && (medium != null || expanded != null)) {
      return (medium ?? expanded)!;
    }
    return compact;
  }

  /// Calculates optimal grid column count for course catalog.
  int get courseGridColumns {
    if (isExpanded) return 3;
    if (isMedium) return 2;
    return 1;
  }
}
