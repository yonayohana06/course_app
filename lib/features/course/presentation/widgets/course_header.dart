import 'package:material_ui/material_ui.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/course.dart';

class CourseHeader extends StatelessWidget {
  final Course course;

  const CourseHeader({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail Banner
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              course.thumbnailUrl.isNotEmpty
                  ? Image.network(
                      course.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.base,
                left: AppSpacing.base,
                right: AppSpacing.base,
                child: Row(
                  children: [
                    AppBadge(
                      label: course.category,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      borderRadius: AppRadius.borderFull,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xxs,
                      ),
                    ),
                    AppSpacing.horizontalSm,
                    AppBadge(
                      label: course.rating.toStringAsFixed(1),
                      icon: Icons.star_rounded,
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      textColor: AppColors.warning,
                      borderRadius: AppRadius.borderFull,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                    ),
                    const Spacer(),
                    AppBadge.level(level: course.level),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Course Info Section
        Padding(
          padding: AppSpacing.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: AppTypography.heading1.copyWith(fontSize: 22),
              ),
              AppSpacing.verticalSm,
              Text(
                course.tagline,
                style: AppTypography.bodyMedium,
              ),
              AppSpacing.verticalBase,

              // Instructor Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: course.instructor.avatarUrl.isNotEmpty
                          ? NetworkImage(course.instructor.avatarUrl)
                          : null,
                      child: course.instructor.avatarUrl.isEmpty
                          ? Text(
                              course.instructor.name.isNotEmpty
                                  ? course.instructor.name[0]
                                  : '?',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.instructor.name,
                            style: AppTypography.titleSmall,
                          ),
                          AppSpacing.verticalXxs,
                          Text(
                            course.instructor.role,
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalBase,
              const Text(
                'Deskripsi Kursus',
                style: AppTypography.heading3,
              ),
              AppSpacing.verticalSm,
              Text(
                course.description,
                style: AppTypography.bodyMedium.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 64,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
