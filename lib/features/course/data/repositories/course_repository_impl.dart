import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/local_course_data_source.dart';

final courseDataSourceProvider = Provider<CourseDataSource>((ref) {
  return const LocalCourseDataSource();
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final dataSource = ref.watch(courseDataSourceProvider);
  return CourseRepositoryImpl(dataSource: dataSource);
});

class CourseRepositoryImpl implements CourseRepository {
  final CourseDataSource dataSource;
  final Duration simulatedDelay;
  final bool shouldFail;

  CourseRepositoryImpl({
    required this.dataSource,
    this.simulatedDelay = Duration.zero,
    this.shouldFail = false,
  });

  @override
  Future<List<Course>> getCourses() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    if (shouldFail) {
      throw Exception('Gagal memuat data kursus: Terjadi kesalahan jaringan.');
    }
    return dataSource.getCourses();
  }

  @override
  Future<Course> getCourseById(String id) async {
    final courses = await getCourses();
    return courses.firstWhere(
      (course) => course.id == id,
      orElse: () => throw Exception('Kursus dengan ID $id tidak ditemukan.'),
    );
  }

  @override
  Future<Lesson> getLessonById(String courseId, String lessonId) async {
    final course = await getCourseById(courseId);
    return course.lessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => throw Exception('Materi dengan ID $lessonId tidak ditemukan.'),
    );
  }
}
