import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/destination_model.dart';

const double _kCardThumbnailSize = 88;
const double _kThumbnailBorderRadius = 8;

/// List item card: image, name, category, location.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final Destination destination;
  final VoidCallback onTap;

  String get _locationLine {
    final address = destination.address?.trim();
    if (address != null && address.isNotEmpty) {
      return address;
    }
    return '${destination.latitude.toStringAsFixed(4)}, '
        '${destination.longitude.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(imageUrl: destination.imageUrl, scheme: scheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _locationLine,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.imageUrl,
    required this.scheme,
  });

  final String? imageUrl;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kThumbnailBorderRadius),
      child: SizedBox(
        width: _kCardThumbnailSize,
        height: _kCardThumbnailSize,
        child: url == null || url.isEmpty
            ? _PlaceholderContent(scheme: scheme)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _PlaceholderContent(scheme: scheme),
              ),
      ),
    );
  }
}

/// Fills the parent [SizedBox]; clipping is done by [_Thumbnail]'s [ClipRRect].
class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: scheme.onSurfaceVariant,
          size: 36,
        ),
      ),
    );
  }
}
