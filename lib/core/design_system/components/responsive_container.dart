import 'package:material_ui/material_ui.dart';
import '../tokens/app_breakpoints.dart';
import '../tokens/app_spacing.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: context.responsiveValue<double>(
            compact: AppSpacing.base,
            medium: AppSpacing.xl,
            expanded: AppSpacing.xxl,
          ),
        );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
