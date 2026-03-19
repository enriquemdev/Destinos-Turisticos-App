import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Dio client for OpenTripMap API.
/// Assumes [dotenv.load] has been called before first use.
class ApiClient {
  ApiClient._();

  static const String _baseUrl = 'https://api.opentripmap.com/0.1/en/';
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  static Dio? _instance;

  /// Returns a configured Dio instance. Creates it on first call.
  static Dio create() {
    if (_instance != null) return _instance!;
    _instance = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
      ),
    )..interceptors.add(LogInterceptor());
    return _instance!;
  }

  /// OpenTripMap API key from .env. Empty if not loaded.
  static String get apiKey => dotenv.env['OPENTRIPMAP_API_KEY'] ?? '';
}
