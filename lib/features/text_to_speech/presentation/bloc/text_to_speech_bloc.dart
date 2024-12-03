import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

part 'text_to_speech_event.dart';
part 'text_to_speech_state.dart';

class TextToSpeechBloc extends Bloc<TextToSpeechEvent, TextToSpeechState> {
  final AudioPlayer audioPlayer;

  TextToSpeechBloc({required this.audioPlayer}) : super(TextToSpeechInitial()) {
    on<ConvertTextToSpeech>(_onConvertTextToSpeech);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
  }

  Future<void> _onConvertTextToSpeech(
    ConvertTextToSpeech event,
    Emitter<TextToSpeechState> emit,
  ) async {
    emit(TextToSpeechLoading());
    try {
      // TODO: Implement API call to convert text to speech
      emit(TextToSpeechSuccess());
    } catch (e) {
      emit(TextToSpeechError(e.toString()));
    }
  }

  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<TextToSpeechState> emit,
  ) async {
    try {
      await audioPlayer.play();
    } catch (e) {
      emit(TextToSpeechError(e.toString()));
    }
  }

  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<TextToSpeechState> emit,
  ) async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      emit(TextToSpeechError(e.toString()));
    }
  }
}
