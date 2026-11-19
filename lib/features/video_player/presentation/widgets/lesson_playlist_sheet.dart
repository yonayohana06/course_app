import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../course/domain/entities/lesson.dart';

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
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Materi Kursus',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${lessons.length} video',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderLight),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: lessons.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 64, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isActive = lesson.id == activeLessonId;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.play_arrow_rounded,
                              size: 18, color: Colors.white)
                          : Text(
                              '${lesson.order}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  subtitle: Text(
                    lesson.duration,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: isActive
                      ? const Text(
                          'Diputar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!isActive) {
                      onSelectLesson(lesson);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
