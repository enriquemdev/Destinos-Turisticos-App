import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Footer for the destination list: load-more button, loading state, or end-of-list.
class DestinationListFooter extends StatelessWidget {
  const DestinationListFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMorePages,
    required this.onLoadMore,
  });

  final bool isLoadingMore;
  final bool hasMorePages;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: isLoadingMore
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Cargando más destinos…',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: scheme.onSurface.withAlpha(160),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : hasMorePages
                ? FilledButton.tonal(
                    onPressed: onLoadMore,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Obtener más destinos',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.travel_explore_outlined,
                        size: 28,
                        color: scheme.onSurface.withAlpha(100),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay más destinos por ahora',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: scheme.onSurface.withAlpha(140),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Has explorado todos los destinos disponibles.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: scheme.onSurface.withAlpha(100),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
      ),
    );
  }
}
