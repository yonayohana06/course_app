import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/course/presentation/screens/course_list_screen.dart';
import '../features/course/presentation/screens/course_detail_screen.dart';
import '../features/video_player/presentation/screens/lesson_player_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/courses',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/courses',
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) => const CourseListScreen(),
        routes: [
          GoRoute(
            path: ':courseId',
            name: 'course_detail',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'] ?? '';
              return CourseDetailScreen(courseId: courseId);
            },
            routes: [
              GoRoute(
                path: 'lessons/:lessonId',
                name: 'lesson_player',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId'] ?? '';
                  final lessonId = state.pathParameters['lessonId'] ?? '';
                  return LessonPlayerScreen(
                    key: ValueKey('player-$courseId-$lessonId'),
                    courseId: courseId,
                    lessonId: lessonId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
