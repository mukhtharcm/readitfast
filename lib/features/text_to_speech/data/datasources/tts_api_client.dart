import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/tts_response.dart';

part 'tts_api_client.g.dart';

// const baseUrl = 'http://localhost:8787';
const baseUrl = 'https://lol.76545689.xyz';

@RestApi(baseUrl: baseUrl)
abstract class TTSApiClient {
  factory TTSApiClient(Dio dio, {String baseUrl}) = _TTSApiClient;

  @POST("/api/tts")
  Future<TTSResponse> convertTextToSpeech(@Body() Map<String, String> body);
}
