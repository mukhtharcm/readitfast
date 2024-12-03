import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/tts_response.dart';

part 'tts_api_client.g.dart';

@RestApi(baseUrl: "http://localhost:8787")
abstract class TTSApiClient {
  factory TTSApiClient(Dio dio, {String baseUrl}) = _TTSApiClient;

  @POST("/api/tts")
  Future<TTSResponse> convertTextToSpeech(@Body() Map<String, String> body);
}
