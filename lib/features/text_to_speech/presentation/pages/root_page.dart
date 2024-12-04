import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/text_to_speech_bloc.dart';
import '../widgets/audio_player_bar.dart';
import 'home_page.dart';
import 'history_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<TextToSpeechBloc, TextToSpeechState>(
      builder: (context, state) {
        final audioPlayer = context.read<TextToSpeechBloc>().audioPlayer;
        final isPlaying = state is TextToSpeechSuccess && state.recentConversions.isNotEmpty;
        final currentText = state is TextToSpeechSuccess && state.recentConversions.isNotEmpty 
            ? state.recentConversions.first.text 
            : '';

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPlaying) AudioPlayerBar(
                audioPlayer: audioPlayer,
                text: currentText,
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.navigationBarTheme.backgroundColor?.withOpacity(0.9) 
                      ?? theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                          label: 'Home',
                          index: 0,
                          theme: theme,
                        ),
                        _buildNavItem(
                          icon: Icons.history_outlined,
                          selectedIcon: Icons.history_rounded,
                          label: 'History',
                          index: 1,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurface.withOpacity(0.7);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withOpacity(0.3) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
