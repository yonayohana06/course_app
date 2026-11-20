import 'package:material_ui/material_ui.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../course/domain/entities/lesson.dart';

class LessonPlaylistPanel extends StatelessWidget {
  final List<Lesson> lessons;
  final String activeLessonId;
  final ValueChanged<Lesson> onSelectLesson;
  final bool isBottomSheet;

  const LessonPlaylistPanel({
    super.key,
    required this.lessons,
    required this.activeLessonId,
    required this.onSelectLesson,
    this.isBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final panelContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBottomSheet) ...[
          AppSpacing.verticalMd,
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: AppRadius.borderXs,
              ),
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.base,
            isBottomSheet ? AppSpacing.md : AppSpacing.base,
            AppSpacing.base,
            AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Daftar Materi Kursus',
                  style: AppTypography.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.horizontalSm,
              Text(
                '${lessons.length} video',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderLight),
        if (isBottomSheet)
          Flexible(
            child: _buildLessonList(context, isScrollable: true),
          )
        else
          _buildLessonList(context, isScrollable: false),
      ],
    );

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      borderRadius: isBottomSheet ? AppRadius.borderTopXl : null,
      shape: isBottomSheet
          ? null
          : const RoundedRectangleBorder(
              borderRadius: AppRadius.borderLg,
              side: BorderSide(color: AppColors.borderLight),
            ),
      child: panelContent,
    );
  }

  Widget _buildLessonList(BuildContext context, {required bool isScrollable}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: lessons.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 60,
        color: AppColors.borderLight,
      ),
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isActive = lesson.id == activeLessonId;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: 2,
          ),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : Text(
                      '${lesson.order}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          title: Text(
            lesson.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textPrimaryLight,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                lesson.duration,
                style: AppTypography.labelSmall,
              ),
              if (isActive) ...[
                AppSpacing.horizontalXs,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: Text(
                    'Diputar',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            if (isBottomSheet) {
              Navigator.of(context).pop();
            }
            if (!isActive) {
              onSelectLesson(lesson);
            }
          },
        );
      },
    );
  }
}
