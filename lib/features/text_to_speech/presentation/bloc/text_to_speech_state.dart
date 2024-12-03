part of 'text_to_speech_bloc.dart';

abstract class TextToSpeechState extends Equatable {
  const TextToSpeechState();
  
  @override
  List<Object> get props => [];
}

class TextToSpeechInitial extends TextToSpeechState {}

class TextToSpeechLoading extends TextToSpeechState {}

class TextToSpeechSuccess extends TextToSpeechState {}

class TextToSpeechError extends TextToSpeechState {
  final String message;

  const TextToSpeechError(this.message);

  @override
  List<Object> get props => [message];
}
