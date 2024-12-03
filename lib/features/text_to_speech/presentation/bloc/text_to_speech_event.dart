part of 'text_to_speech_bloc.dart';

abstract class TextToSpeechEvent extends Equatable {
  const TextToSpeechEvent();

  @override
  List<Object> get props => [];
}

class ConvertTextToSpeech extends TextToSpeechEvent {
  final String text;

  const ConvertTextToSpeech(this.text);

  @override
  List<Object> get props => [text];
}

class PlayAudio extends TextToSpeechEvent {}

class PauseAudio extends TextToSpeechEvent {}
