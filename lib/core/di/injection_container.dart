import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/text_to_speech/data/datasources/tts_api_client.dart';
import '../../features/text_to_speech/data/repositories/tts_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => AudioPlayer());

  final dio = Dio()..interceptors.add(LogInterceptor(responseBody: true));
  sl.registerLazySingleton(() => dio);

  // API Client
  sl.registerLazySingleton(
    () => TTSApiClient(sl(), baseUrl: baseUrl),
  );

  // Repository
  sl.registerLazySingleton(() => TTSRepository(sl()));
}
