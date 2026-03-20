import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-bleed background image for the detail SliverAppBar.
///
/// Extracted from [DetailScreen] so it can be referenced from both
/// the [SliverAppBar] flexibleSpace and the Hero widget.
class DetailHeroBackground extends StatelessWidget {
  const DetailHeroBackground({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = imageUrl?.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image or placeholder
        url == null || url.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withAlpha(200),
                      scheme.secondary.withAlpha(160),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.landscape_rounded,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (ctx, url) => Container(color: scheme.surfaceContainerHighest),
                errorWidget: (ctx, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withAlpha(200),
                        scheme.secondary.withAlpha(160),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.broken_image_rounded,
                      size: 64, color: Colors.white54),
                ),
              ),
        // Bottom gradient for AppBar title legibility
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(180),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
