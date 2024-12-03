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

  void _cyclePlaybackSpeed() {
    final currentSpeed = audioPlayer.speed;
    final speeds = [0.5, 1.0, 1.5, 2.0];
    final currentIndex = speeds.indexOf(currentSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;
    audioPlayer.setSpeed(speeds[nextIndex]);
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
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Cover Art
            Container(
              width: 280,
              height: 280,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  firstLetter,
                  style: GoogleFonts.inter(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color:
                        theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Text Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            // Progress Bar
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(Duration.zero, Duration.zero, Duration.zero);

                return Column(
                  children: [
                    // Time indicators
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    const SizedBox(height: 8),
                    // Progress Slider
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
                        inactiveTrackColor:
                            theme.colorScheme.surfaceContainerHighest,
                        thumbColor: theme.colorScheme.primary,
                        overlayColor:
                            theme.colorScheme.primary.withOpacity(0.12),
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
                  ],
                );
              },
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<double>(
                    stream: audioPlayer.speedStream,
                    builder: (context, snapshot) {
                      final speed = snapshot.data ?? 1.0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: _cyclePlaybackSpeed,
                          child: Text(
                            '${speed}x',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded),
                        iconSize: 32,
                        color: theme.colorScheme.onSurface,
                        onPressed: () {
                          final newPosition = audioPlayer.position -
                              const Duration(seconds: 10);
                          audioPlayer.seek(
                            Duration(
                                milliseconds: newPosition.inMilliseconds.clamp(
                                    0,
                                    audioPlayer.duration?.inMilliseconds ?? 0)),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
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
                            icon = Icons.pause_circle_filled_rounded;
                          } else {
                            icon = Icons.play_circle_filled_rounded;
                          }

                          return Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primaryContainer,
                            ),
                            child: IconButton(
                              onPressed: _handlePlayPause,
                              icon: Icon(
                                icon,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded),
                        iconSize: 32,
                        color: theme.colorScheme.onSurface,
                        onPressed: () {
                          final newPosition = audioPlayer.position +
                              const Duration(seconds: 10);
                          audioPlayer.seek(
                            Duration(
                                milliseconds: newPosition.inMilliseconds.clamp(
                                    0,
                                    audioPlayer.duration?.inMilliseconds ?? 0)),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_snippet_rounded),
                    iconSize: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Full Text',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                text,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
