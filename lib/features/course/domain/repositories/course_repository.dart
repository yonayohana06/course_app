import '../entities/course.dart';
import '../entities/lesson.dart';

abstract class CourseRepository {
  /// Retrieves the list of all available courses.
  Future<List<Course>> getCourses();

  /// Retrieves a specific course by its unique [id].
  Future<Course> getCourseById(String id);

  /// Retrieves a specific lesson inside a course.
  Future<Lesson> getLessonById(String courseId, String lessonId);
}
