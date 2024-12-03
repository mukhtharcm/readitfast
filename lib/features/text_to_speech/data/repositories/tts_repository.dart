import '../datasources/tts_api_client.dart';
import '../models/tts_response.dart';

class TTSRepository {
  final TTSApiClient _apiClient;

  TTSRepository(this._apiClient);

  Future<TTSResponse> convertTextToSpeech(String text) async {
    try {
      return await _apiClient.convertTextToSpeech({'text': text});
    } catch (e) {
      throw Exception('Failed to convert text to speech: $e');
    }
  }
}
