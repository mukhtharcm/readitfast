// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TTSResponse _$TTSResponseFromJson(Map<String, dynamic> json) => TTSResponse(
      audioUrl: json['audioUrl'] as String,
      duration: (json['duration'] as num).toDouble(),
      text: json['text'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$TTSResponseToJson(TTSResponse instance) =>
    <String, dynamic>{
      'audioUrl': instance.audioUrl,
      'duration': instance.duration,
      'text': instance.text,
      'timestamp': instance.timestamp,
    };
