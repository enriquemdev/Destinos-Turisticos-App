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
class DestinationsRemoteDataSource {
  DestinationsRemoteDataSource({Dio? dio})
      : _dio = dio ?? ApiClient.create();

  final Dio _dio;

  static const double _managuaLat = 12.1328;
  static const double _managuaLon = -86.2917;
  static const int _radiusMeters = 20000;
  static const int _limit = 50;

  /// Fetches a list of places near Managua.
  /// Returns partial [Destination] objects (no description/image).
  Future<List<Destination>> fetchDestinationsList() async {
    try {
      final response = await _dio.get<dynamic>(
        'places/radius',
        queryParameters: {
          'radius': _radiusMeters,
          'lon': _managuaLon,
          'lat': _managuaLat,
          'kinds': 'interesting_places',
          'limit': _limit,
          'format': 'json',
          'apikey': ApiClient.apiKey,
        },
      );

      final data = response.data;
      if (data is! List) {
        throw RemoteDataSourceException('Invalid response: expected list');
      }

      return _parsePlaceList(data);
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  /// Fetches full details for a place by xid.
  Future<Destination> fetchPlaceDetails(String xid) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'places/xid/$xid',
        queryParameters: {'apikey': ApiClient.apiKey},
      );

      final data = response.data;
      if (data == null) {
        throw RemoteDataSourceException('Empty response for xid: $xid');
      }

      return _parsePlaceDetails(data, xid);
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  List<Destination> _parsePlaceList(List<dynamic> items) {
    final result = <Destination>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final dest = _parsePlaceListItem(item);
      if (dest != null) result.add(dest);
    }
    return result;
  }

  Destination? _parsePlaceListItem(Map<String, dynamic> json) {
    final xid = json['xid'] as String?;
    final name = json['name'] as String?;
    final point = json['point'] as Map<String, dynamic>?;
    if (xid == null || name == null || point == null) return null;

    final lat = _parseDouble(point['lat']);
    final lon = _parseDouble(point['lon']);
    if (lat == null || lon == null) return null;

    final kinds = json['kinds'];
    final category = _kindsToCategory(kinds);

    return Destination(
      xid: xid,
      name: name,
      description: null,
      imageUrl: null,
      category: category,
      latitude: lat,
      longitude: lon,
      address: null,
      url: null,
      wikipedia: null,
      osm: null,
      rate: _parseDouble(json['rate']),
    );
  }

  Destination _parsePlaceDetails(Map<String, dynamic> json, String xid) {
    final name = json['name'] as String? ?? '';
    final point = json['point'] as Map<String, dynamic>?;
    final lat = _parseDouble(point?['lat']) ?? 0.0;
    final lon = _parseDouble(point?['lon']) ?? 0.0;
    final kinds = json['kinds'];
    final category = _kindsToCategory(kinds);

    final description = json['description'] as String?;
    final imageUrl = _extractImageUrl(json);
    final address = _formatAddress(json['address']);
    final url = json['url'] as String?;
    final wikipedia = json['wikipedia'] as String?;
    final osm = json['osm'] as String?;
    final rate = _parseDouble(json['rate']);

    return Destination(
      xid: xid,
      name: name,
      description: description,
      imageUrl: imageUrl,
      category: category,
      latitude: lat,
      longitude: lon,
      address: address,
      url: url,
      wikipedia: wikipedia,
      osm: osm,
      rate: rate,
    );
  }

  String _kindsToCategory(dynamic kinds) {
    if (kinds == null) return 'place';
    if (kinds is String) return kinds.split(',').first.trim();
    if (kinds is List && kinds.isNotEmpty) {
      return (kinds.first as String?) ?? 'place';
    }
    return 'place';
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
      for (final key in ['road', 'house_number', 'city', 'state', 'country']) {
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
    final message = e.message ?? 'Unknown error';

    if (statusCode != null) {
      if (statusCode == 401) {
        return RemoteDataSourceException('Invalid or missing API key');
      }
      if (statusCode >= 500) {
        return RemoteDataSourceException('Server error. Try again later.');
      }
      if (statusCode == 404) {
        return RemoteDataSourceException('Place not found');
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return RemoteDataSourceException('Connection timeout. Check your network.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return RemoteDataSourceException('No internet connection');
    }

    return RemoteDataSourceException(message);
  }
}
