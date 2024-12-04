import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import '../bloc/text_to_speech_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = context.read<TextToSpeechBloc>().audioPlayer;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<TextToSpeechBloc, TextToSpeechState>(
        listener: (context, state) {
          if (state is TextToSpeechError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background gradient and pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.tertiary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: BubblePainter(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      animation: _animation.value,
                    ),
                  ),
                ),
              ),
              // Main content
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App title with gradient
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.tertiary,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'ReadItFast',
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Transform text into speech,\neffortlessly.',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                height: 1.4,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: size.height * 0.06),
                            // Text input card
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.edit_rounded,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Your Text',
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: theme.colorScheme.outline.withOpacity(0.1),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _textController,
                                      maxLines: 7,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        height: 1.5,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Type or paste your text here...',
                                        hintStyle: GoogleFonts.inter(
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(20),
                                      ),
                                    ),
                                  ),
                                  // Convert button
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: state is TextToSpeechLoading
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primaryContainer,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        theme.colorScheme.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Converting...',
                                                    style: GoogleFonts.inter(
                                                      color: theme.colorScheme.primary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : FilledButton.icon(
                                              onPressed: () {
                                                if (_textController.text.trim().isEmpty) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Please enter some text to convert',
                                                        style: GoogleFonts.inter(),
                                                      ),
                                                      backgroundColor: theme.colorScheme.error,
                                                      behavior: SnackBarBehavior.floating,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                context.read<TextToSpeechBloc>().add(
                                                  ConvertTextToSpeech(_textController.text),
                                                );
                                              },
                                              style: FilledButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 32,
                                                  vertical: 20,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              icon: const Icon(Icons.record_voice_over_rounded),
                                              label: Text(
                                                'Convert to Speech',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final double animation;
  final Color color;

  BubblePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bubblePositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.9, size.height * 0.7),
    ];

    for (var i = 0; i < bubblePositions.length; i++) {
      final position = bubblePositions[i];
      final radius = (30 + (20 * sin((animation + i) * 2 * pi))) * (1 + i * 0.2);
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
