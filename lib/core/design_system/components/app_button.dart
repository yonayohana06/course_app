import 'package:material_ui/material_ui.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.outline;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    Color effectiveForegroundColor;
    if (!isEnabled) {
      effectiveForegroundColor = const Color(0xFF94A3B8); // Slate 400 (disabled)
    } else if (variant == AppButtonVariant.outline ||
        variant == AppButtonVariant.text) {
      effectiveForegroundColor = AppColors.primary;
    } else {
      effectiveForegroundColor = Colors.white;
    }

    Widget content;

    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: effectiveForegroundColor,
        ),
      );
    } else {
      final textWidget = Text(
        label,
        style: AppTypography.button.copyWith(
          color: effectiveForegroundColor,
        ),
      );

      if (icon != null) {
        content = Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: effectiveForegroundColor,
            ),
            AppSpacing.horizontalSm,
            textWidget,
          ],
        );
      } else {
        content = textWidget;
      }
    }

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? AppColors.primary : const Color(0xFFE2E8F0),
            foregroundColor:
                isEnabled ? Colors.white : const Color(0xFF94A3B8),
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            disabledForegroundColor: const Color(0xFF94A3B8),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
          onPressed: isEnabled ? onPressed : null,
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? AppColors.primaryLight : const Color(0xFFE2E8F0),
            foregroundColor:
                isEnabled ? Colors.white : const Color(0xFF94A3B8),
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            disabledForegroundColor: const Color(0xFF94A3B8),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
          onPressed: isEnabled ? onPressed : null,
          child: content,
        );
        break;

      case AppButtonVariant.outline:
        button = OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: const Color(0xFF94A3B8),
            backgroundColor:
                isEnabled ? Colors.transparent : const Color(0xFFF8FAFC),
            disabledBackgroundColor: const Color(0xFFF8FAFC),
            side: BorderSide(
              color: isEnabled
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
          onPressed: isEnabled ? onPressed : null,
          child: content,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: const Color(0xFF94A3B8),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
          onPressed: isEnabled ? onPressed : null,
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
