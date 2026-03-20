import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/nearby_poi.dart';
import '../store/destination_store.dart';

/// "Explorar Alrededores" section for the detail screen.
///
/// Lazy-loads POIs from OTM radius search when first rendered.
/// Groups POIs by display category and shows them as sorted chips.
class NearbyPoisSection extends StatefulWidget {
  const NearbyPoisSection({
    super.key,
    required this.store,
    required this.latitude,
    required this.longitude,
  });

  final DestinationStore store;
  final double latitude;
  final double longitude;

  @override
  State<NearbyPoisSection> createState() => _NearbyPoisSectionState();
}

class _NearbyPoisSectionState extends State<NearbyPoisSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.store.loadNearbyPois(widget.latitude, widget.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Observer(
      builder: (_) {
        final pois = widget.store.nearbyPois;
        final isLoading = widget.store.isLoadingNearby;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surfaceContainerHighest.withAlpha(60)
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outline.withAlpha(40),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    'Explorar alrededores',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '5 km',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: scheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isLoading)
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Buscando lugares cercanos…',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: scheme.onSurface.withAlpha(150),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              else if (pois.isEmpty)
                Text(
                  'No se encontraron lugares de interés cercanos.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: scheme.onSurface.withAlpha(120),
                  ),
                )
              else
                _PoisList(pois: pois.toList(), scheme: scheme),
            ],
          ),
        );
      },
    );
  }
}

class _PoisList extends StatelessWidget {
  const _PoisList({required this.pois, required this.scheme});

  final List<NearbyPoi> pois;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // Group by category
    final grouped = <String, List<NearbyPoi>>{};
    for (final poi in pois) {
      final cat = poi.displayCategory;
      grouped.putIfAbsent(cat, () => []).add(poi);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category label
              Text(
                entry.key,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withAlpha(160),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              // POI chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((poi) => _PoiChip(poi: poi, scheme: scheme)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PoiChip extends StatelessWidget {
  const _PoiChip({required this.poi, required this.scheme});

  final NearbyPoi poi;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(poi.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              poi.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (poi.distanceLabel.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              poi.distanceLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: scheme.onSurface.withAlpha(120),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
