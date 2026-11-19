import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_app/features/course/domain/entities/course.dart';
import 'package:course_app/features/course/domain/entities/instructor.dart';
import 'package:course_app/features/course/domain/entities/lesson.dart';
import 'package:course_app/features/course/domain/repositories/course_repository.dart';
import 'package:course_app/features/course/data/repositories/mock_course_repository.dart';
import 'package:course_app/features/video_player/domain/entities/player_state.dart';
import 'package:course_app/features/video_player/presentation/controllers/lesson_player_controller.dart';

class FakePlayerRepository implements CourseRepository {
  final Course course;

  FakePlayerRepository(this.course);

  @override
  Future<List<Course>> getCourses() async => [course];

  @override
  Future<Course> getCourseById(String id) async {
    if (id == course.id) return course;
    throw Exception('Course not found');
  }

  @override
  Future<Lesson> getLessonById(String courseId, String lessonId) async {
    return course.lessons.firstWhere((l) => l.id == lessonId);
  }
}

void main() {
  const dummyCourse = Course(
    id: 'c1',
    title: 'Flutter Architecture',
    tagline: 'Deep dive',
    description: 'Learn architecture',
    instructor: Instructor(name: 'Dev', role: 'Lead', avatarUrl: ''),
    thumbnailUrl: '',
    category: 'Tech',
    level: 'Advanced',
    totalDuration: '20 min',
    rating: 5.0,
    lessonsCount: 2,
    lessons: [
      Lesson(
        id: 'l1',
        courseId: 'c1',
        order: 1,
        title: 'Lesson 1',
        duration: '10:00',
        durationSeconds: 600,
        videoUrl: 'https://example.com/v1.mp4',
        summary: 'Intro',
      ),
      Lesson(
        id: 'l2',
        courseId: 'c1',
        order: 2,
        title: 'Lesson 2',
        duration: '10:00',
        durationSeconds: 600,
        videoUrl: 'https://example.com/v2.mp4',
        summary: 'Deep dive',
      ),
    ],
  );

  group('LessonPlayerController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          courseRepositoryProvider
              .overrideWithValue(FakePlayerRepository(dummyCourse)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state before init is initial', () {
      final state = container.read(lessonPlayerControllerProvider);
      expect(state.status, PlayerStatus.initial);
    });

    test('initialize loads course and lesson metadata', () async {
      final controller =
          container.read(lessonPlayerControllerProvider.notifier);

      await controller.loadLesson(courseId: 'c1', lessonId: 'l1');

      final state = container.read(lessonPlayerControllerProvider);
      expect(state.course?.id, 'c1');
      expect(state.currentLesson?.id, 'l1');
      expect(state.hasPreviousLesson, isFalse);
      expect(state.hasNextLesson, isTrue);
      expect(state.nextLesson?.id, 'l2');
    });

    test('switching to second lesson updates next and previous flags', () async {
      final controller =
          container.read(lessonPlayerControllerProvider.notifier);

      await controller.loadLesson(courseId: 'c1', lessonId: 'l2');

      final state = container.read(lessonPlayerControllerProvider);
      expect(state.currentLesson?.id, 'l2');
      expect(state.hasPreviousLesson, isTrue);
      expect(state.hasNextLesson, isFalse);
      expect(state.previousLesson?.id, 'l1');
    });

    test('handles non-existent course error cleanly', () async {
      final controller =
          container.read(lessonPlayerControllerProvider.notifier);

      await controller.loadLesson(courseId: 'invalid_id', lessonId: 'l1');

      final state = container.read(lessonPlayerControllerProvider);
      expect(state.status, PlayerStatus.error);
      expect(state.errorMessage, isNotNull);
    });
  });
}
