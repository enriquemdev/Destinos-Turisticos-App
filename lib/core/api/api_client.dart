import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Dio clients for all external APIs.
class ApiClient {
  ApiClient._();

  // OpenTripMap

  static const String _otmBaseUrl = 'https://api.opentripmap.com/0.1/en/';

  static Dio? _otmInstance;

  static Dio create() {
    if (_otmInstance != null) return _otmInstance!;
    _otmInstance = Dio(
      BaseOptions(
        baseUrl: _otmBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )..interceptors.add(LogInterceptor());
    return _otmInstance!;
  }

  static String get apiKey => dotenv.env['OPENTRIPMAP_API_KEY'] ?? '';

  // Gemini

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/';

  static Dio? _geminiInstance;

  static Dio createGemini() {
    if (_geminiInstance != null) return _geminiInstance!;
    _geminiInstance = Dio(
      BaseOptions(
        baseUrl: _geminiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors
        .add(LogInterceptor(requestBody: false, responseBody: false));
    return _geminiInstance!;
  }

  static String get geminiApiKey =>
      dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY'] ?? '';

  // Nominatim (OSM geocoding — requires User-Agent)

  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org/';

  static Dio? _nominatimInstance;

  static Dio createNominatim() {
    if (_nominatimInstance != null) return _nominatimInstance!;
    _nominatimInstance = Dio(
      BaseOptions(
        baseUrl: _nominatimBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        // Nominatim requires a valid User-Agent identifying the app
        headers: {
          'User-Agent': 'DestinosTuristicosApp/1.0 (enriquemdev@gmail.com)',
          'Accept-Language': 'es',
        },
      ),
    );
    return _nominatimInstance!;
  }

  // Wikidata

  static const String _wikidataBaseUrl = 'https://www.wikidata.org/w/';

  static Dio? _wikidataInstance;

  static Dio createWikidata() {
    if (_wikidataInstance != null) return _wikidataInstance!;
    _wikidataInstance = Dio(
      BaseOptions(
        baseUrl: _wikidataBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent': 'DestinosTuristicosApp/1.0 (enriquemdev@gmail.com)',
        },
      ),
    );
    return _wikidataInstance!;
  }
}
