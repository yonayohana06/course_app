class Lesson {
  final String id;
  final String courseId;
  final int order;
  final String title;
  final String duration;
  final int durationSeconds;
  final String videoUrl;
  final String summary;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.order,
    required this.title,
    required this.duration,
    required this.durationSeconds,
    required this.videoUrl,
    required this.summary,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          courseId == other.courseId &&
          order == other.order &&
          title == other.title &&
          duration == other.duration &&
          durationSeconds == other.durationSeconds &&
          videoUrl == other.videoUrl &&
          summary == other.summary;

  @override
  int get hashCode =>
      id.hashCode ^
      courseId.hashCode ^
      order.hashCode ^
      title.hashCode ^
      duration.hashCode ^
      durationSeconds.hashCode ^
      videoUrl.hashCode ^
      summary.hashCode;
}
