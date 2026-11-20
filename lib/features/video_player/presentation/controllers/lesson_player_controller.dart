import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../course/data/repositories/course_repository_impl.dart';
import '../../domain/entities/player_state.dart';

class LessonPlayerParam {
  final String courseId;
  final String lessonId;

  const LessonPlayerParam({
    required this.courseId,
    required this.lessonId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonPlayerParam &&
          courseId == other.courseId &&
          lessonId == other.lessonId;

  @override
  int get hashCode => courseId.hashCode ^ lessonId.hashCode;
}

final lessonDetailProvider =
    FutureProvider.family<LessonPlayerState, LessonPlayerParam>(
        (ref, param) async {
  final repository = ref.watch(courseRepositoryProvider);
  final course = await repository.getCourseById(param.courseId);
  final lesson = course.lessons.firstWhere(
    (l) => l.id == param.lessonId,
    orElse: () =>
        throw Exception('Materi dengan ID ${param.lessonId} tidak ditemukan.'),
  );

  return LessonPlayerState(
    status: PlayerStatus.ready,
    course: course,
    currentLesson: lesson,
  );
});

final lessonPlayerControllerProvider =
    NotifierProvider<LessonPlayerController, LessonPlayerState>(
  LessonPlayerController.new,
);

class LessonPlayerController extends Notifier<LessonPlayerState> {
  @override
  LessonPlayerState build() {
    return const LessonPlayerState();
  }

  Future<void> loadLesson({
    required String courseId,
    required String lessonId,
  }) async {
    state = state.copyWith(
      status: PlayerStatus.loading,
      errorMessage: null,
    );

    try {
      final repository = ref.read(courseRepositoryProvider);
      final course = await repository.getCourseById(courseId);
      final lesson = course.lessons.firstWhere(
        (l) => l.id == lessonId,
        orElse: () =>
            throw Exception('Materi dengan ID $lessonId tidak ditemukan.'),
      );

      state = state.copyWith(
        status: PlayerStatus.ready,
        course: course,
        currentLesson: lesson,
      );
    } catch (e) {
      state = state.copyWith(
        status: PlayerStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void updatePlaybackState({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
  }) {
    state = state.copyWith(
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      position: position,
      duration: duration,
    );
  }

  void reset() {
    state = const LessonPlayerState();
  }
}
