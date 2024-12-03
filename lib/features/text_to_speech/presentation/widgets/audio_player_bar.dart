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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      const SizedBox(height: 4),
                      StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data ??
                              PositionData(
                                  Duration.zero, Duration.zero, Duration.zero);

                          return Stack(
                            children: [
                              // Buffered Progress
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: positionData.duration.inMilliseconds >
                                          0
                                      ? positionData
                                              .bufferedPosition.inMilliseconds /
                                          positionData.duration.inMilliseconds
                                      : 0,
                                  backgroundColor: theme
                                      .colorScheme.onSecondaryContainer
                                      .withOpacity(0.12),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onSecondaryContainer
                                        .withOpacity(0.24),
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              // Actual Progress
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: positionData.duration.inMilliseconds >
                                          0
                                      ? positionData.position.inMilliseconds /
                                          positionData.duration.inMilliseconds
                                      : 0,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onSecondaryContainer,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data ??
                              PositionData(
                                  Duration.zero, Duration.zero, Duration.zero);
                          return Text(
                            '${_formatDuration(positionData.position)} / ${_formatDuration(positionData.duration)}',
                            style: GoogleFonts.inter(
                              color: theme.colorScheme.onSecondaryContainer
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                StreamBuilder<PlayerState>(
                  stream: audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.replay_10_rounded,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          iconSize: 20,
                          onPressed: () => audioPlayer.seek(
                            audioPlayer.position - const Duration(seconds: 10),
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSecondaryContainer
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              (processingState == ProcessingState.loading ||
                                      processingState ==
                                          ProcessingState.buffering)
                                  ? Icons.hourglass_bottom_rounded
                                  : playing ?? false
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                              size: 24,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            onPressed: () {
                              if (playing ?? false) {
                                context
                                    .read<TextToSpeechBloc>()
                                    .add(PauseAudio());
                              } else {
                                context
                                    .read<TextToSpeechBloc>()
                                    .add(PlayAudio());
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.forward_10_rounded,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          iconSize: 20,
                          onPressed: () => audioPlayer.seek(
                            audioPlayer.position + const Duration(seconds: 10),
                          ),
                        ),
                      ],
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showFullScreenPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => FullScreenPlayer(
          audioPlayer: audioPlayer,
          text: text,
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
