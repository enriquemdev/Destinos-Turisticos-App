import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-width hero image for the destination detail header.
class DetailHeroImage extends StatelessWidget {
  const DetailHeroImage({
    super.key,
    required this.imageUrl,
    required this.scheme,
  });

  final String? imageUrl;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: url == null || url.isEmpty
          ? ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, _) => ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
    );
  }
}
