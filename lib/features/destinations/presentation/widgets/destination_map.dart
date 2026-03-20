import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Fixed height map with OSM tiles and a marker at [latitude] / [longitude].
///
/// Intended for use inside scrollable content ([keepAlive] avoids reset on scroll).
class DestinationMap extends StatelessWidget {
  const DestinationMap({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  static const double _mapHeight = 250;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final point = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: _mapHeight,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            backgroundColor: scheme.surfaceContainerHighest,
            keepAlive: true,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'destinos_turisticos_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 44,
                  height: 44,
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    Icons.location_on,
                    size: 44,
                    color: scheme.primary,
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
