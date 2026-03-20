import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../domain/dtos/destinations/nearby_poi_dto.dart';

/// Fixed height map showing the main destination pin + optional nearby POI pins.
class DestinationMap extends StatelessWidget {
  const DestinationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.nearbyPois = const [],
  });

  final double latitude;
  final double longitude;
  final List<NearbyPoiDto> nearbyPois;

  static const double _mapHeight = 260;
  static const double _defaultZoom = 14;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mainPoint = LatLng(latitude, longitude);

    final MapOptions mapOptions;
    if (nearbyPois.isEmpty) {
      mapOptions = MapOptions(
        initialCenter: mainPoint,
        initialZoom: _defaultZoom,
        backgroundColor: scheme.surfaceContainerHighest,
        keepAlive: true,
      );
    } else {
      final allPoints = [
        mainPoint,
        ...nearbyPois.map((p) => LatLng(p.latitude, p.longitude)),
      ];
      final bounds = LatLngBounds.fromPoints(allPoints);
      mapOptions = MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
        ),
        backgroundColor: scheme.surfaceContainerHighest,
        keepAlive: true,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _mapHeight,
        child: FlutterMap(
          options: mapOptions,
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'destinos_turisticos_app',
            ),
            MarkerLayer(
              markers: [
                ...nearbyPois.map(
                  (poi) => Marker(
                    point: LatLng(poi.latitude, poi.longitude),
                    width: 28,
                    height: 28,
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      Icons.location_on,
                      size: 28,
                      color: scheme.tertiary,
                    ),
                  ),
                ),
                Marker(
                  point: mainPoint,
                  width: 48,
                  height: 48,
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    Icons.location_on,
                    size: 48,
                    color: scheme.primary,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black38),
                    ],
                  ),
                ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
