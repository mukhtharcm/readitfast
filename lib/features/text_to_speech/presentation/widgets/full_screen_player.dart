import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/text_to_speech_bloc.dart';
import 'package:rxdart/rxdart.dart';

class FullScreenPlayer extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final String text;

  const FullScreenPlayer({
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
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Text Display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              // Audio Progress
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data ??
                      PositionData(Duration.zero, Duration.zero, Duration.zero);

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: theme.colorScheme.primary,
                          inactiveTrackColor: theme.colorScheme.surfaceVariant,
                          thumbColor: theme.colorScheme.primary,
                          overlayColor: theme.colorScheme.primary.withOpacity(0.12),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: positionData.duration.inMilliseconds.toDouble(),
                          value: positionData.position.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            audioPlayer.seek(
                              Duration(milliseconds: value.round()),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(positionData.position),
                              style: GoogleFonts.inter(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(positionData.duration),
                              style: GoogleFonts.inter(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              // Playback Controls
              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded),
                        iconSize: 32,
                        onPressed: () => audioPlayer.seek(
                          audioPlayer.position - const Duration(seconds: 10),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            (processingState == ProcessingState.loading ||
                                    processingState == ProcessingState.buffering)
                                ? Icons.hourglass_bottom_rounded
                                : playing ?? false
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                            size: 32,
                          ),
                          onPressed: () {
                            if (playing ?? false) {
                              context.read<TextToSpeechBloc>().add(PauseAudio());
                            } else {
                              context.read<TextToSpeechBloc>().add(PlayAudio());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded),
                        iconSize: 32,
                        onPressed: () => audioPlayer.seek(
                          audioPlayer.position + const Duration(seconds: 10),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
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
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
