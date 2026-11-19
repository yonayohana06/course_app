import 'package:material_ui/material_ui.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: AppColors.borderLight),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with gradient overlay & badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: course.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          course.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: AppBadge(
                    label: course.category,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                    textColor: Colors.white,
                    borderRadius: AppRadius.borderFull,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xxs,
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: AppBadge(
                    label: course.rating.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    textColor: AppColors.warning,
                    borderRadius: AppRadius.borderFull,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: AppSpacing.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.heading3,
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    course.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
                  ),
                  AppSpacing.verticalMd,
                  const Divider(height: 1, color: AppColors.borderLight),
                  AppSpacing.verticalMd,
                  // Metadata row: Instructor, lessons, duration
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          course.instructor.name.isNotEmpty
                              ? course.instructor.name[0]
                              : '?',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          course.instructor.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            size: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                          AppSpacing.horizontalXxs,
                          Text(
                            '${course.lessonsCount} materi',
                            style: AppTypography.labelSmall,
                          ),
                          AppSpacing.horizontalSm,
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                          AppSpacing.horizontalXxs,
                          Text(
                            course.totalDuration,
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 48,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
