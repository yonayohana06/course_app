import 'package:material_ui/material_ui.dart';
import '../../../course/domain/entities/lesson.dart';
import 'lesson_playlist_panel.dart';

class LessonPlaylistSheet extends StatelessWidget {
  final List<Lesson> lessons;
  final String activeLessonId;
  final ValueChanged<Lesson> onSelectLesson;

  const LessonPlaylistSheet({
    super.key,
    required this.lessons,
    required this.activeLessonId,
    required this.onSelectLesson,
  });

  @override
  Widget build(BuildContext context) {
    return LessonPlaylistPanel(
      lessons: lessons,
      activeLessonId: activeLessonId,
      onSelectLesson: onSelectLesson,
      isBottomSheet: true,
    );
  }
}
