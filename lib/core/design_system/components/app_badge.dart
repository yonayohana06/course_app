import 'package:material_ui/material_ui.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum AppBadgeVariant {
  primary,
  secondary,
  success,
  warning,
  info,
  outline,
}

class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderSide? border;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.border,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
    this.borderRadius = AppRadius.borderSm,
    this.onTap,
  });

  /// Factory for category chip
  factory AppBadge.category({
    Key? key,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return AppBadge(
      key: key,
      label: label,
      backgroundColor: isSelected
          ? AppColors.primary
          : AppColors.backgroundLight,
      textColor: isSelected
          ? Colors.white
          : AppColors.textPrimaryLight,
      border: isSelected
          ? null
          : const BorderSide(color: AppColors.borderLight),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.borderFull,
      onTap: onTap,
    );
  }

  /// Factory for course difficulty level
  factory AppBadge.level({
    Key? key,
    required String level,
  }) {
    Color bg;
    Color fg;
    final normalized = level.toLowerCase();

    if (normalized.contains('pemula') || normalized.contains('beginner')) {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = const Color(0xFF047857);
    } else if (normalized.contains('menengah') || normalized.contains('intermediate')) {
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = const Color(0xFFB45309);
    } else {
      bg = AppColors.primaryLight.withValues(alpha: 0.15);
      fg = AppColors.primary;
    }

    return AppBadge(
      key: key,
      label: level,
      backgroundColor: bg,
      textColor: fg,
      borderRadius: AppRadius.borderSm,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }

  /// Factory for rating badge (e.g. 4.8 ★)
  factory AppBadge.rating({
    Key? key,
    required double rating,
    int? reviewCount,
  }) {
    final labelText = reviewCount != null
        ? '${rating.toStringAsFixed(1)} ($reviewCount)'
        : rating.toStringAsFixed(1);

    return AppBadge(
      key: key,
      label: labelText,
      icon: Icons.star_rounded,
      backgroundColor: const Color(0xFFFEF3C7),
      textColor: const Color(0xFF92400E),
      borderRadius: AppRadius.borderSm,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }

  /// Factory for informational info badge with icon (e.g. duration, lesson count)
  factory AppBadge.info({
    Key? key,
    required String label,
    IconData? icon,
  }) {
    return AppBadge(
      key: key,
      label: label,
      icon: icon,
      backgroundColor: AppColors.backgroundLight,
      textColor: AppColors.textSecondaryLight,
      borderRadius: AppRadius.borderSm,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.textPrimaryLight;
    final effectiveBgColor = backgroundColor ?? AppColors.backgroundLight;

    Widget badgeContent = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 14,
            color: effectiveTextColor,
          ),
          AppSpacing.horizontalXxs,
        ],
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: borderRadius,
        border: border != null ? Border.fromBorderSide(border!) : null,
      ),
      child: badgeContent,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: container,
      );
    }

    return container;
  }
}
