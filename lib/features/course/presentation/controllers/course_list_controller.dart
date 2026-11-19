import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/course.dart';
import '../../data/repositories/mock_course_repository.dart';

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Semua';

  void setCategory(String category) {
    state = category;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
  SelectedCategoryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final courseListControllerProvider =
    AsyncNotifierProvider<CourseListController, List<Course>>(
  CourseListController.new,
);

class CourseListController extends AsyncNotifier<List<Course>> {
  @override
  FutureOr<List<Course>> build() async {
    final repository = ref.watch(courseRepositoryProvider);
    return repository.getCourses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(courseRepositoryProvider);
      return repository.getCourses();
    });
  }
}

final filteredCourseListProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final coursesAsync = ref.watch(courseListControllerProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return coursesAsync.whenData((courses) {
    return courses.where((course) {
      final matchesCategory = category == 'Semua' || course.category == category;
      final matchesQuery = query.isEmpty ||
          course.title.toLowerCase().contains(query) ||
          course.tagline.toLowerCase().contains(query) ||
          course.instructor.name.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});
