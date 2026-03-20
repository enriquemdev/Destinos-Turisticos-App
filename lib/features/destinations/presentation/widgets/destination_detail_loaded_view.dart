import 'package:flutter/material.dart';

import '../../data/models/destination_model.dart';
import 'destination_map.dart';
import 'detail_hero_image.dart';

/// Scrollable detail content when a [Destination] is available.
class DestinationDetailLoadedView extends StatelessWidget {
  const DestinationDetailLoadedView({
    super.key,
    required this.destination,
  });

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final address = destination.address?.trim();
    final desc = destination.description?.trim();
    final url = destination.url?.trim();
    final wiki = destination.wikipedia?.trim();
    final osm = destination.osm?.trim();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailHeroImage(imageUrl: destination.imageUrl, scheme: scheme),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    destination.category,
                    style: theme.textTheme.labelSmall,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: scheme.outlineVariant),
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                if (destination.rate != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 22,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        destination.rate!.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
                if (address != null && address.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (desc != null && desc.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
                if (url != null && url.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Sitio web',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    url,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
                if (wiki != null && wiki.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Wikipedia',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    wiki,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
                if (osm != null && osm.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'OSM: $osm',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Ubicación',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DestinationMap(
                  latitude: destination.latitude,
                  longitude: destination.longitude,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
