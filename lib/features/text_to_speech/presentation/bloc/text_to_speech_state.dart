part of 'text_to_speech_bloc.dart';

abstract class TextToSpeechState extends Equatable {
  const TextToSpeechState();
  
  @override
  List<Object> get props => [];
}

class TextToSpeechInitial extends TextToSpeechState {}

class TextToSpeechLoading extends TextToSpeechState {}

class TextToSpeechSuccess extends TextToSpeechState {
  final List<TTSResponse> recentConversions;
  
  const TextToSpeechSuccess({
    this.recentConversions = const [],
  });
  
  @override
  List<Object> get props => [recentConversions];
  
  TextToSpeechSuccess copyWith({
    List<TTSResponse>? recentConversions,
  }) {
    return TextToSpeechSuccess(
      recentConversions: recentConversions ?? this.recentConversions,
    );
  }
}

class TextToSpeechError extends TextToSpeechState {
  final String message;

  const TextToSpeechError(this.message);

  @override
  List<Object> get props => [message];
}
