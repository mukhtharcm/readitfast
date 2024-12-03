import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readitfast/core/di/injection_container.dart' as di;
import 'package:readitfast/features/text_to_speech/presentation/bloc/text_to_speech_bloc.dart';
import 'package:readitfast/features/text_to_speech/presentation/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TextToSpeechBloc(
        audioPlayer: di.sl(),
        repository: di.sl(),
      ),
      child: MaterialApp(
        title: 'ReadItFast',
        theme: FlexThemeData.light(
          scheme: FlexScheme.blue,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.blue,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const HomePage(),
      ),
    );
  }
}
