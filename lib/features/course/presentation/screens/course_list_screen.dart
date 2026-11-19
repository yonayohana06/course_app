import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../controllers/course_list_controller.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(courseListControllerProvider);
    final filteredCoursesAsync = ref.watch(filteredCourseListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'E-Learning Platform',
              style: AppTypography.heading2,
            ),
            Text(
              'Tingkatkan skill engineering Anda',
              style: AppTypography.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
            onPressed: () {
              ref.read(courseListControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const AppLoadingIndicator(
          message: 'Memuat daftar kursus...',
        ),
        error: (err, stack) => ErrorStateView(
          message: err.toString().replaceAll('Exception: ', ''),
          onRetry: () {
            ref.read(courseListControllerProvider.notifier).refresh();
          },
        ),
        data: (allCourses) {
          if (allCourses.isEmpty) {
            return EmptyStateView(
              onAction: () =>
                  ref.read(courseListControllerProvider.notifier).refresh(),
              actionLabel: 'Muat Ulang',
            );
          }

          final categories = [
            'Semua',
            ...{for (final c in allCourses) c.category},
          ];

          return Column(
            children: [
              // Search bar with Design System Component
              AppSearchField(
                controller: _searchController,
                hintText: 'Cari kursus atau instruktur...',
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.sm,
                  AppSpacing.base,
                  AppSpacing.sm,
                ),
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).setQuery(val);
                },
                onClear: () {
                  ref.read(searchQueryProvider.notifier).setQuery('');
                },
              ),

              // Category chips with AppBadge
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      AppSpacing.horizontalSm,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCategory;
                    return AppBadge.category(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .setCategory(cat);
                      },
                    );
                  },
                ),
              ),

              AppSpacing.verticalSm,

              // Filtered list or empty filter message
              Expanded(
                child: filteredCoursesAsync.when(
                  loading: () => const AppLoadingIndicator(),
                  error: (err, _) => ErrorStateView(
                    message: err.toString(),
                    onRetry: () => ref
                        .read(courseListControllerProvider.notifier)
                        .refresh(),
                  ),
                  data: (filteredList) {
                    if (filteredList.isEmpty) {
                      return EmptyStateView(
                        title: 'Tidak ada kursus yang cocok',
                        message:
                            'Coba ubah kata kunci pencarian atau kategori filter.',
                        icon: Icons.search_off_rounded,
                        onAction: () {
                          ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory('Semua');
                          ref.read(searchQueryProvider.notifier).setQuery('');
                          _searchController.clear();
                        },
                        actionLabel: 'Reset Filter',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(courseListControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base,
                          AppSpacing.sm,
                          AppSpacing.base,
                          AppSpacing.xl,
                        ),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) =>
                            AppSpacing.verticalBase,
                        itemBuilder: (context, index) {
                          final course = filteredList[index];
                          return CourseCard(
                            course: course,
                            onTap: () {
                              context.go('/courses/${course.id}');
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
