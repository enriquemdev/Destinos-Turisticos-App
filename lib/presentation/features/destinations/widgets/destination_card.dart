import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/dtos/destinations/destination_dto.dart';
import 'category_badge.dart';

/// Premium full-image card for the destination list.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final DestinationDto destination;
  final VoidCallback onTap;

  static const double _cardHeight = 220;

  String get _locationLine {
    final address = destination.address?.trim();
    if (address != null && address.isNotEmpty) return address;
    return '${destination.latitude.toStringAsFixed(3)}, '
        '${destination.longitude.toStringAsFixed(3)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'destination_image_${destination.xid}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: _cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: scheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CardImage(imageUrl: destination.imageUrl, scheme: scheme),
                const _GradientOverlay(),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CategoryBadge(category: destination.category),
                      const SizedBox(height: 6),
                      Text(
                        destination.name,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (destination.highlight != null &&
                          destination.highlight!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          destination.highlight!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withAlpha(220),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationLine,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
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
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl, required this.scheme});

  final String? imageUrl;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty || url == '__no_image__') {
      return _PlaceholderImage(scheme: scheme);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (ctx, url) => _PlaceholderImage(scheme: scheme),
      errorWidget: (ctx, url, error) => _PlaceholderImage(scheme: scheme),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withAlpha(140),
            scheme.secondary.withAlpha(100),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.landscape_rounded, size: 64, color: Colors.white54),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35, 1.0],
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(30),
            Colors.black.withAlpha(200),
          ],
        ),
      ),
    );
  }
}
