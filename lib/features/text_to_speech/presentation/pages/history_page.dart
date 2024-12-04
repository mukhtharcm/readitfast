import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/text_to_speech_bloc.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _getTimeAgo(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            stretch: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'History',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.tertiary,
                      theme.colorScheme.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
            builder: (context, state) {
              if (state is TextToSpeechSuccess) {
                if (state.recentConversions.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No history yet'),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = state.recentConversions[index];
                      final firstLetter = item.text.isNotEmpty ? item.text[0].toUpperCase() : 'T';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                final audioPlayer = context.read<TextToSpeechBloc>().audioPlayer;
                                audioPlayer.setUrl(item.audioUrl);
                                context.read<TextToSpeechBloc>().add(PlayAudio());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Letter Avatar
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
                                        children: [
                                          Text(
                                            item.text,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 14,
                                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getTimeAgo(item.timestamp),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 14,
                                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${item.duration.toStringAsFixed(1)}s',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: state.recentConversions.length,
                  ),
                );
              }
              return const SliverFillRemaining(
                child: Center(
                  child: Text('No history available'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
