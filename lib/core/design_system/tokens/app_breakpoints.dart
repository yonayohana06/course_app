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

  /// Whether current orientation is landscape.
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Whether current orientation is portrait.
  bool get isPortrait =>
      MediaQuery.orientationOf(this) == Orientation.portrait;

  /// Whether current screen height is compact (< 480 dp), typical of phones in landscape.
  bool get isCompactHeight => screenHeight < 480.0;

  /// Whether current device is a smartphone in landscape orientation.
  bool get isPhoneLandscape => isLandscape && isCompactHeight;

  /// Whether to use two-column split view.
  /// On tablets/foldables in portrait (e.g. iPad 11" 820x1180), height dominates width,
  /// so a centered single-column layout is cleaner than squeezing content horizontally.
  /// Split view is enabled when:
  /// - Screen width is >= 700 dp and in landscape (both tablets and phones in landscape)
  /// - Or on extra-wide screens (width >= 1000 dp).
  bool get useSplitView =>
      (screenWidth >= 700.0 && isLandscape) || screenWidth >= 1000.0;

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
    if (isExpanded) {
      // In landscape phone (e.g. iPhone 15 852x393), 2 columns prevents cramped cards.
      if (isCompactHeight) return 2;
      return 3;
    }
    if (isMedium) return 2;
    return 1;
  }
}
