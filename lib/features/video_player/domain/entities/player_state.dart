import '../../../course/domain/entities/course.dart';
import '../../../course/domain/entities/lesson.dart';

enum PlayerStatus {
  initial,
  loading,
  ready,
  error,
}

class LessonPlayerState {
  final PlayerStatus status;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final Lesson? currentLesson;
  final Course? course;

  const LessonPlayerState({
    this.status = PlayerStatus.initial,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.currentLesson,
    this.course,
  });

  bool get hasPreviousLesson {
    if (course == null || currentLesson == null) return false;
    final index = course!.lessons.indexWhere((l) => l.id == currentLesson!.id);
    return index > 0;
  }

  bool get hasNextLesson {
    if (course == null || currentLesson == null) return false;
    final index = course!.lessons.indexWhere((l) => l.id == currentLesson!.id);
    return index >= 0 && index < course!.lessons.length - 1;
  }

  Lesson? get previousLesson {
    if (!hasPreviousLesson) return null;
    final index = course!.lessons.indexWhere((l) => l.id == currentLesson!.id);
    return course!.lessons[index - 1];
  }

  Lesson? get nextLesson {
    if (!hasNextLesson) return null;
    final index = course!.lessons.indexWhere((l) => l.id == currentLesson!.id);
    return course!.lessons[index + 1];
  }

  LessonPlayerState copyWith({
    PlayerStatus? status,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    Lesson? currentLesson,
    Course? course,
  }) {
    return LessonPlayerState(
      status: status ?? this.status,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      currentLesson: currentLesson ?? this.currentLesson,
      course: course ?? this.course,
    );
  }
}
