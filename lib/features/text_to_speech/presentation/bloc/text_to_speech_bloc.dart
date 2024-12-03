import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/tts_response.dart';
import '../../data/repositories/tts_repository.dart';

part 'text_to_speech_event.dart';
part 'text_to_speech_state.dart';

class TextToSpeechBloc extends Bloc<TextToSpeechEvent, TextToSpeechState> {
  final AudioPlayer audioPlayer;
  final TTSRepository repository;
  final List<TTSResponse> _recentConversions = [];
  static const int _maxRecentConversions = 10;

  TextToSpeechBloc({
    required this.audioPlayer,
    required this.repository,
  }) : super(TextToSpeechInitial()) {
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
      final response = await repository.convertTextToSpeech(event.text);
      
      // Add to recent conversations
      _recentConversions.insert(0, response);
      if (_recentConversions.length > _maxRecentConversions) {
        _recentConversions.removeLast();
      }
      
      await audioPlayer.setUrl(response.audioUrl);
      emit(TextToSpeechSuccess(recentConversions: List.from(_recentConversions)));
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
