/// A nearby Point of Interest returned by OpenTripMap radius search.
class NearbyPoi {
  const NearbyPoi({
    required this.name,
    required this.kinds,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
  });

  final String name;

  /// Raw OTM kinds string, e.g. "historic,architecture,cultural"
  final String kinds;
  final double latitude;
  final double longitude;
  final double? distanceMeters;

  // Derived display helpers

  String get displayCategory => _toCategory(kinds);
  String get emoji => _toEmoji(kinds);

  String get distanceLabel {
    final d = distanceMeters;
    if (d == null) return '';
    if (d < 1000) return '${d.round()} m';
    return '${(d / 1000).toStringAsFixed(1)} km';
  }

  // SQLite persistence

  Map<String, dynamic> toMap(String destinationXid) => {
        'destinationXid': destinationXid,
        'name': name,
        'kinds': kinds,
        'latitude': latitude,
        'longitude': longitude,
        'distanceMeters': distanceMeters,
      };

  factory NearbyPoi.fromMap(Map<String, dynamic> map) => NearbyPoi(
        name: map['name'] as String,
        kinds: (map['kinds'] as String?) ?? '',
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      );

  factory NearbyPoi.fromOtmJson(Map<String, dynamic> json) {
    final point = json['point'] as Map<String, dynamic>?;
    final lat = (point?['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (point?['lon'] as num?)?.toDouble() ?? 0.0;
    final dist = (json['dist'] as num?)?.toDouble();

    return NearbyPoi(
      name: (json['name'] as String?)?.trim() ?? 'Sin nombre',
      kinds: (json['kinds'] as String?) ?? '',
      latitude: lat,
      longitude: lon,
      distanceMeters: dist,
    );
  }

  // Category / emoji derivation

  static String _toCategory(String kinds) {
    final k = kinds.toLowerCase();
    if (k.contains('restaurant') || k.contains('food') || k.contains('cafe')) {
      return 'Gastronomía';
    }
    if (k.contains('hotel') || k.contains('accommodation')) return 'Alojamiento';
    if (k.contains('museum') || k.contains('theatre') || k.contains('cultural')) {
      return 'Cultura';
    }
    if (k.contains('historic') || k.contains('monument')) return 'Historia';
    if (k.contains('natural') || k.contains('park')) return 'Naturaleza';
    if (k.contains('beach')) return 'Playa';
    if (k.contains('sport') || k.contains('amusement')) return 'Aventura';
    if (k.contains('shop') || k.contains('market')) return 'Comercio';
    return 'Lugar';
  }

  static String _toEmoji(String kinds) {
    final k = kinds.toLowerCase();
    if (k.contains('restaurant') || k.contains('food') || k.contains('cafe')) {
      return '🍽️';
    }
    if (k.contains('hotel') || k.contains('accommodation')) return '🏨';
    if (k.contains('museum') || k.contains('theatre') || k.contains('cultural')) {
      return '🏛️';
    }
    if (k.contains('historic') || k.contains('monument')) return '🏰';
    if (k.contains('natural') || k.contains('park')) return '🌿';
    if (k.contains('beach')) return '🏖️';
    if (k.contains('sport') || k.contains('amusement')) return '⚡';
    if (k.contains('shop') || k.contains('market')) return '🛍️';
    return '📍';
  }
}
