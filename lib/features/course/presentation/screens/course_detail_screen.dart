import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
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
                      const Text(
                        'Daftar Materi (Lessons)',
                        style: AppTypography.heading3,
                      ),
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
        },
      ),
    );
  }
}
