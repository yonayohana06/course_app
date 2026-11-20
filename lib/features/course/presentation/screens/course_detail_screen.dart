import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/course.dart';
import '../controllers/course_detail_controller.dart';
import '../widgets/course_header.dart';
import '../widgets/lesson_list_tile.dart';
import '../widgets/error_state_view.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kursus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/courses');
            }
          },
        ),
      ),
      body: courseAsync.when(
        loading: () => const AppLoadingIndicator(
          message: 'Memuat detail kursus...',
        ),
        error: (err, _) => ErrorStateView(
          message: err.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.refresh(courseDetailProvider(courseId)),
        ),
        data: (course) {
          final bool isCompact = context.isCompact;

          if (isCompact) {
            return _buildCompactLayout(context, course);
          }

          return _buildWideLayout(context, course);
        },
      ),
    );
  }

  /// Single-column layout optimized for mobile smartphones (< 600 dp)
  Widget _buildCompactLayout(BuildContext context, Course course) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CourseHeader(course: course),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.sm,
              AppSpacing.base,
              AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Materi (Lessons)',
                    style: AppTypography.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.horizontalSm,
                Text(
                  '${course.lessons.length} materi',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final lesson = course.lessons[index];
              return LessonListTile(
                lesson: lesson,
                onTap: () {
                  context.go('/courses/$courseId/lessons/${lesson.id}');
                },
              );
            },
            childCount: course.lessons.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: AppSpacing.verticalXxl,
        ),
      ],
    );
  }

  /// Two-column split layout for tablets and unfolded foldable devices (>= 600 dp)
  Widget _buildWideLayout(BuildContext context, Course course) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveValue<double>(
              compact: AppSpacing.base,
              medium: AppSpacing.base,
              expanded: AppSpacing.lg,
            ),
            vertical: AppSpacing.base,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Course Header & Description (flex 6)
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderLg,
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    elevation: 0,
                    child: CourseHeader(course: course),
                  ),
                ),
              ),

              AppSpacing.horizontalBase,

              // Right Column: Lesson List Panel (flex 4)
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderLg,
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: AppSpacing.paddingCard,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Daftar Materi (Lessons)',
                                  style: AppTypography.heading3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              AppSpacing.horizontalSm,
                              Text(
                                '${course.lessons.length} materi',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          itemCount: course.lessons.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final lesson = course.lessons[index];
                            return LessonListTile(
                              lesson: lesson,
                              onTap: () {
                                context.go(
                                    '/courses/$courseId/lessons/${lesson.id}');
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
