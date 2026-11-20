import 'package:material_ui/material_ui.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/lesson.dart';

class LessonListTile extends StatelessWidget {
  final Lesson lesson;
  final bool isCurrent;
  final VoidCallback onTap;

  const LessonListTile({
    super.key,
    required this.lesson,
    this.isCurrent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(
            color: isCurrent ? AppColors.primaryLight : AppColors.borderLight,
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.xxs,
          ),
          onTap: onTap,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${lesson.order}',
                style: AppTypography.titleSmall.copyWith(
                  color: isCurrent ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          title: Text(
            lesson.title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppColors.textSecondaryLight,
                ),
                AppSpacing.horizontalXxs,
                Text(
                  lesson.duration,
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCurrent ? Icons.play_arrow_rounded : Icons.play_arrow_outlined,
              color: isCurrent ? Colors.white : AppColors.primary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
