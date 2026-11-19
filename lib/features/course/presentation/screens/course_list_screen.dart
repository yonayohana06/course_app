import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/course_list_controller.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Tingkatkan skill engineering Anda',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.9),
              ),
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
        loading: () => const Center(
          child: CircularProgressIndicator(),
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
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari kursus atau instruktur...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              ref.read(searchQueryProvider.notifier).setQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).setQuery(val);
                  },
                ),
              ),

              // Category chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).setCategory(cat);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Filtered list or empty filter message
              Expanded(
                child: filteredCoursesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
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
                          ref.read(selectedCategoryProvider.notifier).setCategory('Semua');
                          ref.read(searchQueryProvider.notifier).setQuery('');
                        },
                        actionLabel: 'Reset Filter',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(courseListControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
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
