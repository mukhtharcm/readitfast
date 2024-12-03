import 'package:json_annotation/json_annotation.dart';

part 'tts_response.g.dart';

@JsonSerializable()
class TTSResponse {
  final String audioUrl;
  final double duration;
  final String text;
  final String timestamp;

  TTSResponse({
    required this.audioUrl,
    required this.duration,
    required this.text,
    required this.timestamp,
  });

  factory TTSResponse.fromJson(Map<String, dynamic> json) =>
      _$TTSResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TTSResponseToJson(this);
}
