import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCurrent ? AppColors.primaryLight : AppColors.borderLight,
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isCurrent ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          title: Text(
            lesson.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  lesson.duration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
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
