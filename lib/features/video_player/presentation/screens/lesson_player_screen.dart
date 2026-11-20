import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../course/domain/entities/lesson.dart';
import '../../../course/presentation/widgets/error_state_view.dart';
import '../../domain/entities/player_state.dart';
import '../controllers/lesson_player_controller.dart';
import '../widgets/lesson_playlist_panel.dart';
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
  String? _currentLoadedVideoUrl;

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.pause();
    _chewieController?.dispose();
    _chewieController = null;

    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _currentLoadedVideoUrl = null;
  }

  Future<void> _initializePlayer(String videoUrl) async {
    if (_currentLoadedVideoUrl == videoUrl && _videoPlayerController != null) {
      return;
    }
    _disposeControllers();
    _currentLoadedVideoUrl = videoUrl;

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
              padding: const EdgeInsets.all(AppSpacing.base),
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

  void _navigateToLesson(String lessonId) {
    context.go('/courses/${widget.courseId}/lessons/$lessonId');
  }

  @override
  Widget build(BuildContext context) {
    final param = LessonPlayerParam(
      courseId: widget.courseId,
      lessonId: widget.lessonId,
    );
    final lessonAsync = ref.watch(lessonDetailProvider(param));

    // Listen to changes in lesson state to trigger video player initialization cleanly
    ref.listen(lessonDetailProvider(param), (previous, next) {
      final nextLesson = next.value?.currentLesson;
      if (nextLesson != null && nextLesson.videoUrl != _currentLoadedVideoUrl) {
        _initializePlayer(nextLesson.videoUrl);
      }
    });

    final bool useSplitView = context.useSplitView;
    final bool isCompactH = context.isCompactHeight;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isCompactH ? 48.0 : kToolbarHeight,
        title: Text(
          lessonAsync.value?.currentLesson?.title ?? 'Pemutar Video',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.heading3,
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
          // Show playlist action button when sidebar playlist is not visible
          if (lessonAsync.value?.course != null && !useSplitView)
            IconButton(
              icon: const Icon(Icons.playlist_play_rounded),
              tooltip: 'Daftar Materi',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => LessonPlaylistSheet(
                    lessons: lessonAsync.value!.course!.lessons,
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
      body: SafeArea(
        top: false,
        left: true,
        right: true,
        bottom: true,
        child: lessonAsync.when(
          loading: () => const AppLoadingIndicator(
            message: 'Memuat data materi...',
          ),
          error: (err, _) => ErrorStateView(
            message: err.toString().replaceAll('Exception: ', ''),
            onRetry: () => ref.refresh(lessonDetailProvider(param)),
          ),
          data: (playerState) {
            final lesson = playerState.currentLesson;
            if (lesson == null) {
              return const Center(child: Text('Materi tidak ditemukan'));
            }

            // Initial load for video player
            if (_videoPlayerController == null &&
                !_isInitializingVideo &&
                _videoError == null &&
                _currentLoadedVideoUrl != lesson.videoUrl) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializePlayer(lesson.videoUrl);
                }
              });
            }

            if (useSplitView) {
              return _buildWideLayout(lesson, playerState);
            }

            return _buildCompactLayout(lesson, playerState);
          },
        ),
      ),
    );
  }

  /// Single-column layout optimized for mobile screens and tablet portrait
  Widget _buildCompactLayout(Lesson lesson, LessonPlayerState playerState) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoViewport(lesson),
              Padding(
                padding: AppSpacing.paddingCard,
                child: _buildLessonDetails(lesson, playerState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Two-column layout for wide screens, tablets, and phones in landscape
  Widget _buildWideLayout(Lesson lesson, LessonPlayerState playerState) {
    final bool isCompactH = context.isCompactHeight;
    // Balanced 58/42 flex on compact landscape (iPhone) gives ample room for playlist titles,
    // while 65/35 is used on spacious tablet/desktop displays.
    final int leftFlex = isCompactH ? 58 : 65;
    final int rightFlex = isCompactH ? 42 : 35;

    final double horizontalPadding = isCompactH
        ? AppSpacing.sm
        : context.responsiveValue<double>(
            compact: AppSpacing.base,
            medium: AppSpacing.xl,
            expanded: AppSpacing.xxl,
          );
    final double verticalPadding = isCompactH ? AppSpacing.xs : AppSpacing.base;
    final double columnSpacing = isCompactH ? AppSpacing.sm : AppSpacing.base;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Video player viewport & lesson info
              Expanded(
                flex: leftFlex,
                child: SingleChildScrollView(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderLg,
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVideoViewport(lesson),
                        Padding(
                          padding: isCompactH
                              ? const EdgeInsets.all(AppSpacing.md)
                              : AppSpacing.paddingCard,
                          child: _buildLessonDetails(lesson, playerState),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: columnSpacing),

              // Right Column: In-place Lesson Playlist Sidebar
              if (playerState.course != null)
                Expanded(
                  flex: rightFlex,
                  child: SingleChildScrollView(
                    child: LessonPlaylistPanel(
                      lessons: playerState.course!.lessons,
                      activeLessonId: widget.lessonId,
                      onSelectLesson: (selected) {
                        _navigateToLesson(selected.id);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoViewport(Lesson lesson) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _videoError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 36,
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        _videoError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      AppSpacing.verticalMd,
                      AppButton(
                        label: 'Coba Lagi',
                        icon: Icons.refresh_rounded,
                        onPressed: () => _initializePlayer(lesson.videoUrl),
                      ),
                    ],
                  ),
                ),
              )
            : _isInitializingVideo || _chewieController == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        AppSpacing.verticalMd,
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
    );
  }

  Widget _buildLessonDetails(Lesson lesson, LessonPlayerState playerState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order & Duration Row
        Row(
          children: [
            AppBadge(
              label: 'Materi #${lesson.order}',
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              textColor: AppColors.primary,
              borderRadius: AppRadius.borderSm,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
            ),
            AppSpacing.horizontalSm,
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: AppColors.textSecondaryLight,
            ),
            AppSpacing.horizontalXxs,
            Text(
              lesson.duration,
              style: AppTypography.labelSmall,
            ),
          ],
        ),
        AppSpacing.verticalSm,
        Text(
          lesson.title,
          style: AppTypography.heading2.copyWith(fontSize: 18),
        ),
        AppSpacing.verticalBase,

        // Next / Previous navigation buttons
        Row(
          children: [
            Expanded(
              child: AppButton.outline(
                icon: Icons.skip_previous_rounded,
                label: 'Sebelumnya',
                onPressed: playerState.hasPreviousLesson
                    ? () {
                        _navigateToLesson(playerState.previousLesson!.id);
                      }
                    : null,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: AppButton(
                icon: Icons.skip_next_rounded,
                label: 'Berikutnya',
                onPressed: playerState.hasNextLesson
                    ? () {
                        _navigateToLesson(playerState.nextLesson!.id);
                      }
                    : null,
              ),
            ),
          ],
        ),

        AppSpacing.verticalLg,
        const Divider(color: AppColors.borderLight),
        AppSpacing.verticalMd,

        // Summary
        const Text(
          'Ringkasan Materi',
          style: AppTypography.heading3,
        ),
        AppSpacing.verticalSm,
        Text(
          lesson.summary,
          style: AppTypography.bodyMedium.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
