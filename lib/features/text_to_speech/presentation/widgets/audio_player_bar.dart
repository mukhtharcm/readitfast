import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readitfast/features/text_to_speech/presentation/widgets/full_screen_player.dart';
import '../bloc/text_to_speech_bloc.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerBar extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final String text;

  const AudioPlayerBar({
    super.key,
    required this.audioPlayer,
    required this.text,
  });

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  void _handlePlayPause() async {
    if (audioPlayer.position >= (audioPlayer.duration ?? Duration.zero)) {
      await audioPlayer.seek(Duration.zero);
      await audioPlayer.play();
    } else if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  void _showFullScreenPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenPlayer(
          audioPlayer: audioPlayer,
          text: text,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstLetter = text.isNotEmpty ? text[0].toUpperCase() : 'T';

    return Container(
      height: 80,
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 24,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFullScreenPlayer(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Cover Letter
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text.length > 30 ? '${text.substring(0, 30)}...' : text,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data ??
                              PositionData(Duration.zero, Duration.zero, Duration.zero);

                          return Row(
                            children: [
                              Text(
                                _formatDuration(positionData.position),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 4,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                    activeTrackColor: theme.colorScheme.primary,
                                    inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                                    thumbColor: theme.colorScheme.primary,
                                    overlayColor: theme.colorScheme.primary.withOpacity(0.12),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: positionData.duration.inMilliseconds.toDouble(),
                                    value: positionData.position.inMilliseconds
                                        .clamp(0, positionData.duration.inMilliseconds)
                                        .toDouble(),
                                    onChanged: (value) {
                                      audioPlayer.seek(
                                        Duration(milliseconds: value.round()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(positionData.duration),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                StreamBuilder<PlayerState>(
                  stream: audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    IconData icon;
                    if (processingState == ProcessingState.completed) {
                      icon = Icons.replay_rounded;
                    } else if (playing == true) {
                      icon = Icons.pause_rounded;
                    } else {
                      icon = Icons.play_arrow_rounded;
                    }

                    return IconButton(
                      onPressed: _handlePlayPause,
                      icon: Icon(
                        icon,
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 32,
                      ),
                    );
                  },
                ),
                StreamBuilder<double>(
                  stream: audioPlayer.speedStream,
                  builder: (context, snapshot) {
                    final speed = snapshot.data ?? 1.0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${speed}x',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
