import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/destination_model.dart';

/// Exception thrown when remote API calls fail.
class RemoteDataSourceException implements Exception {
  RemoteDataSourceException(this.message);

  final String message;

  @override
  String toString() => 'RemoteDataSourceException: $message';
}

/// Fetches destination data from OpenTripMap API.
/// Coordinates can be passed in to support Gemini-driven destination discovery.
class DestinationsRemoteDataSource {
  DestinationsRemoteDataSource({Dio? dio})
      : _dio = dio ?? ApiClient.create();

  final Dio _dio;

  static const int _defaultRadius = 3000; // metres — tighter for precision
  static const int _maxResults = 5;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Finds the best OpenTripMap match near [lat]/[lon].
  ///
  /// Used to enrich Gemini-curated destinations with OTM data.
  Future<Destination?> fetchByCoordinates({
    required double lat,
    required double lon,
    required String name,
    required String category,
    required String highlight,
    int radius = _defaultRadius,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        'places/radius',
        queryParameters: {
          'radius': radius,
          'lon': lon,
          'lat': lat,
          'kinds': _categoryToKinds(category),
          'limit': _maxResults,
          'format': 'json',
          'apikey': ApiClient.apiKey,
        },
      );

      final data = response.data;
      if (data is! List || data.isEmpty) return null;

      // Pick the closest item (first one returned by OTM radius search)
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final xid = item['xid'] as String?;
        if (xid == null || xid.isEmpty) continue;

        // Fetch full details for this xid
        final details = await _fetchDetails(
          xid: xid,
          fallbackName: name,
          fallbackLat: lat,
          fallbackLon: lon,
          category: category,
          highlight: highlight,
        );
        if (details != null) return details;
      }
      return null;
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  /// Fetches full details for a place by xid.
  /// Retries with exponential backoff on 429 (rate limit) responses.
  Future<Destination?> fetchPlaceDetails(
    String xid, {
    String fallbackName = '',
    double fallbackLat = 0.0,
    double fallbackLon = 0.0,
    String fallbackCategory = 'place',
    String fallbackHighlight = '',
  }) async {
    return _fetchDetails(
      xid: xid,
      fallbackName: fallbackName,
      fallbackLat: fallbackLat,
      fallbackLon: fallbackLon,
      category: fallbackCategory,
      highlight: fallbackHighlight,
    );
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  static const int _maxRetries = 3;
  static const Duration _retryBaseDelay = Duration(seconds: 2);

  Future<Destination?> _fetchDetails({
    required String xid,
    required String fallbackName,
    required double fallbackLat,
    required double fallbackLon,
    required String category,
    required String highlight,
  }) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          'places/xid/$xid',
          queryParameters: {'apikey': ApiClient.apiKey},
        );

        final data = response.data;
        if (data == null) return null;

        return _parsePlaceDetails(
          data,
          xid: xid,
          fallbackName: fallbackName,
          fallbackLat: fallbackLat,
          fallbackLon: fallbackLon,
          category: category,
          highlight: highlight,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 429 && attempt < _maxRetries) {
          await Future<void>.delayed(_retryBaseDelay * (attempt + 1));
          continue;
        }
        // Non-404 errors bubble up; 404 means no match found
        if (e.response?.statusCode == 404) return null;
        throw _translateDioException(e);
      }
    }
    return null;
  }

  Destination _parsePlaceDetails(
    Map<String, dynamic> json, {
    required String xid,
    required String fallbackName,
    required double fallbackLat,
    required double fallbackLon,
    required String category,
    required String highlight,
  }) {
    final name = (json['name'] as String?)?.trim();
    final point = json['point'] as Map<String, dynamic>?;
    final lat = _parseDouble(point?['lat']) ?? fallbackLat;
    final lon = _parseDouble(point?['lon']) ?? fallbackLon;

    final description = (json['description'] as String?)?.trim();
    final imageUrl = _extractImageUrl(json);
    final address = _formatAddress(json['address']);
    final url = json['url'] as String?;
    final wikipedia = json['wikipedia'] as String?;
    final osm = json['osm'] as String?;
    final rate = _parseDouble(json['rate']);

    return Destination(
      xid: xid,
      name: (name != null && name.isNotEmpty) ? name : fallbackName,
      description: (description != null && description.isNotEmpty)
          ? description
          : null,
      imageUrl: imageUrl,
      category: category,
      latitude: lat,
      longitude: lon,
      address: address,
      url: url,
      wikipedia: wikipedia,
      osm: osm,
      rate: rate,
      highlight: highlight,
      aiTips: null,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Map our category strings to OTM kinds.
  String _categoryToKinds(String category) {
    switch (category) {
      case 'naturaleza':
        return 'natural,national_parks';
      case 'cultura':
        return 'cultural,museums';
      case 'historia':
        return 'historic,architecture';
      case 'playa':
        return 'beaches';
      case 'aventura':
        return 'sport,amusements';
      case 'gastronomia':
        return 'foods';
      case 'ciudad':
        return 'historic,architecture,cultural';
      default:
        return 'interesting_places';
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _extractImageUrl(Map<String, dynamic> json) {
    final image = json['image'] as String?;
    if (image != null && image.isNotEmpty) return image;
    final preview = json['preview'] as Map<String, dynamic>?;
    if (preview != null) {
      final source = preview['source'] as String?;
      if (source != null && source.isNotEmpty) return source;
    }
    return null;
  }

  String? _formatAddress(dynamic address) {
    if (address == null) return null;
    if (address is String) return address.isEmpty ? null : address;
    if (address is Map<String, dynamic>) {
      final parts = <String>[];
      for (final key in ['road', 'house_number', 'suburb', 'city', 'state', 'country']) {
        final v = address[key];
        if (v != null && v.toString().isNotEmpty) {
          parts.add(v.toString());
        }
      }
      return parts.isEmpty ? null : parts.join(', ');
    }
    return null;
  }

  RemoteDataSourceException _translateDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return RemoteDataSourceException('Invalid or missing OpenTripMap API key');
    }
    if (statusCode == 429) {
      return RemoteDataSourceException('Rate limit exceeded. Try again later.');
    }
    if (statusCode != null && statusCode >= 500) {
      return RemoteDataSourceException('OpenTripMap server error. Try again later.');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return RemoteDataSourceException('Connection timeout. Check your network.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return RemoteDataSourceException('No internet connection');
    }
    return RemoteDataSourceException(e.message ?? 'Unknown error');
  }
}
