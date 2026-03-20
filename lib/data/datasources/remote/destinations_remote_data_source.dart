import 'package:dio/dio.dart';

import '../../../app/config/api_client.dart';
import '../../../domain/dtos/destinations/nearby_poi_dto.dart';

/// Exception thrown when OTM API calls fail.
class RemoteDataSourceException implements Exception {
  RemoteDataSourceException(this.message);
  final String message;

  @override
  String toString() => 'RemoteDataSourceException: $message';
}

/// Fetches nearby Points of Interest from OpenTripMap.
///
/// Used exclusively for the "Explorar Alrededores" feature in the detail screen.
/// A single radius call returns all POIs — no per-item detail calls needed.
class DestinationsRemoteDataSource {
  DestinationsRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.create();

  final Dio _dio;

  static const int _defaultRadius = 5000;
  static const int _maxPois = 20;

  Future<List<NearbyPoiDto>> fetchNearbyPois({
    required double lat,
    required double lon,
    int radiusMeters = _defaultRadius,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        'places/radius',
        queryParameters: {
          'radius': radiusMeters,
          'lon': lon,
          'lat': lat,
          'kinds': 'interesting_places',
          'limit': _maxPois,
          'format': 'json',
          'apikey': ApiClient.apiKey,
        },
      );

      final data = response.data;
      if (data is! List) return [];

      final pois = <NearbyPoiDto>[];
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final name = (item['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        pois.add(_poiFromOtmJson(item));
      }
      return pois;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw RemoteDataSourceException('Invalid OTM API key');
      if (status == 429) throw RemoteDataSourceException('OTM rate limit exceeded');
      if (e.type == DioExceptionType.connectionError) {
        throw RemoteDataSourceException('No internet connection');
      }
      throw RemoteDataSourceException(e.message ?? 'Network error');
    }
  }

  NearbyPoiDto _poiFromOtmJson(Map<String, dynamic> json) {
    final point = json['point'] as Map<String, dynamic>?;
    final lat = (point?['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (point?['lon'] as num?)?.toDouble() ?? 0.0;
    final dist = (json['dist'] as num?)?.toDouble();

    return NearbyPoiDto(
      name: (json['name'] as String?)?.trim() ?? 'Sin nombre',
      kinds: (json['kinds'] as String?) ?? '',
      latitude: lat,
      longitude: lon,
      distanceMeters: dist,
    );
  }
}
