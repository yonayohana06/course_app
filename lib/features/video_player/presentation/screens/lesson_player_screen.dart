import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../course/presentation/widgets/error_state_view.dart';
import '../../domain/entities/player_state.dart';
import '../controllers/lesson_player_controller.dart';
import '../widgets/lesson_playlist_sheet.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String lessonId;

  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializingVideo = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndInit();
    });
  }

  @override
  void didUpdateWidget(covariant LessonPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId ||
        oldWidget.courseId != widget.courseId) {
      _disposeControllers();
      _loadDataAndInit();
    }
  }

  Future<void> _loadDataAndInit() async {
    await ref.read(lessonPlayerControllerProvider.notifier).loadLesson(
          courseId: widget.courseId,
          lessonId: widget.lessonId,
        );

    final state = ref.read(lessonPlayerControllerProvider);
    if (state.currentLesson != null) {
      await _initializePlayer(state.currentLesson!.videoUrl);
    }
  }

  Future<void> _initializePlayer(String videoUrl) async {
    _disposeControllers();

    if (!mounted) return;
    setState(() {
      _isInitializingVideo = true;
      _videoError = null;
    });

    try {
      final uri = Uri.parse(videoUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memutar video: $errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          );
        },
      );

      setState(() {
        _videoPlayerController = controller;
        _chewieController = chewie;
        _isInitializingVideo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializingVideo = false;
        _videoError =
            'Gagal memuat video stream: Terjadi kendala koneksi atau URL tidak valid.';
      });
    }
  }

  void _disposeControllers() {
    _chewieController?.pause();
    _chewieController?.dispose();
    _chewieController = null;

    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _navigateToLesson(String lessonId) {
    context.go('/courses/${widget.courseId}/lessons/$lessonId');
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(lessonPlayerControllerProvider);
    final lesson = playerState.currentLesson;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson?.title ?? 'Pemutar Video',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/courses/${widget.courseId}');
            }
          },
        ),
        actions: [
          if (playerState.course != null)
            IconButton(
              icon: const Icon(Icons.playlist_play_rounded),
              tooltip: 'Daftar Materi',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => LessonPlaylistSheet(
                    lessons: playerState.course!.lessons,
                    activeLessonId: widget.lessonId,
                    onSelectLesson: (selected) {
                      _navigateToLesson(selected.id);
                    },
                  ),
                );
              },
            ),
        ],
      ),
      body: playerState.status == PlayerStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : playerState.status == PlayerStatus.error
              ? ErrorStateView(
                  message: playerState.errorMessage ?? 'Terjadi kesalahan.',
                  onRetry: _loadDataAndInit,
                )
              : lesson == null
                  ? const Center(child: Text('Materi tidak ditemukan'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Video Player Viewport
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: Colors.black,
                              child: _videoError != null
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              color: AppColors.error,
                                              size: 36,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _videoError!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryLight,
                                              ),
                                              onPressed: () =>
                                                  _initializePlayer(
                                                      lesson.videoUrl),
                                              child: const Text('Coba Lagi'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : _isInitializingVideo ||
                                          _chewieController == null
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                'Menyiapkan pemutar video...',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Chewie(
                                          controller: _chewieController!,
                                        ),
                            ),
                          ),

                          // Lesson info and switcher controls
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order & Duration Row
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Materi #${lesson.order}',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.access_time_rounded,
                                        size: 14,
                                        color: AppColors.textSecondaryLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      lesson.duration,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  lesson.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryLight,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Next / Previous navigation buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(
                                            Icons.skip_previous_rounded,
                                            size: 18),
                                        label: const Text('Sebelumnya'),
                                        onPressed:
                                            playerState.hasPreviousLesson
                                                ? () {
                                                    _navigateToLesson(
                                                        playerState
                                                            .previousLesson!.id);
                                                  }
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.skip_next_rounded,
                                            size: 18),
                                        label: const Text('Berikutnya'),
                                        onPressed: playerState.hasNextLesson
                                            ? () {
                                                _navigateToLesson(playerState
                                                    .nextLesson!.id);
                                              }
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                const Divider(color: AppColors.borderLight),
                                const SizedBox(height: 12),

                                // Summary
                                const Text(
                                  'Ringkasan Materi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  lesson.summary,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondaryLight,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
