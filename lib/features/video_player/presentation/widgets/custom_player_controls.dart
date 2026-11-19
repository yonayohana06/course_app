import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';

class CustomPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onSkipForward;
  final VoidCallback onSkipBackward;

  const CustomPlayerControls({
    super.key,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSkipForward,
    required this.onSkipBackward,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final maxSeconds = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
    final currentSeconds = position.inSeconds.toDouble().clamp(0.0, maxSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar & duration text
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryLight,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: currentSeconds,
                    min: 0.0,
                    max: maxSeconds,
                    onChanged: (val) {
                      onSeek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Action buttons: -10s, Play/Pause, +10s
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                iconSize: 28,
                tooltip: 'Mundur 10 detik',
                onPressed: onSkipBackward,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: isBuffering
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        iconSize: 32,
                        tooltip: isPlaying ? 'Pause' : 'Play',
                        onPressed: onPlayPause,
                      ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                iconSize: 28,
                tooltip: 'Maju 10 detik',
                onPressed: onSkipForward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
