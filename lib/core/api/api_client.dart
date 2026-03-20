import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Dio clients for OpenTripMap and Gemini APIs.
class ApiClient {
  ApiClient._();

  // OpenTripMap

  static const String _otmBaseUrl = 'https://api.opentripmap.com/0.1/en/';

  static Dio? _otmInstance;

  /// Returns a configured Dio instance for OpenTripMap.
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

  /// OpenTripMap API key from .env.
  static String get apiKey => dotenv.env['OPENTRIPMAP_API_KEY'] ?? '';

  // Gemini

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/';

  static Dio? _geminiInstance;

  /// Returns a configured Dio instance for Gemini REST API.
  static Dio createGemini() {
    if (_geminiInstance != null) return _geminiInstance!;
    _geminiInstance = Dio(
      BaseOptions(
        baseUrl: _geminiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
    return _geminiInstance!;
  }

  /// Gemini API key from .env.
  static String get geminiApiKey =>
      dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY'] ?? '';
}
