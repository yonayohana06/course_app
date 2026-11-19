import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/course.dart';
import '../../data/repositories/mock_course_repository.dart';

final courseDetailProvider =
    FutureProvider.family<Course, String>((ref, courseId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getCourseById(courseId);
});
