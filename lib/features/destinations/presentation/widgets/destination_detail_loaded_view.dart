import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/destination_model.dart';
import '../store/destination_store.dart';
import 'category_badge.dart';
import 'destination_map.dart';
import 'nearby_pois_section.dart';

/// Scrollable content shown when a [Destination] is fully loaded.
class DestinationDetailLoadedView extends StatelessWidget {
  const DestinationDetailLoadedView({
    super.key,
    required this.destination,
    required this.store,
  });

  final Destination destination;
  final DestinationStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final address = destination.address?.trim();
    final desc = destination.description?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          CategoryBadge(category: destination.category, onDark: false),
          const SizedBox(height: 12),

          // Title
          Text(
            destination.name,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
              height: 1.15,
            ),
          ),

          // Highlight tagline
          if (destination.highlight != null && destination.highlight!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              destination.highlight!,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: scheme.primary,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Location
          if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.place_rounded,
              text: address,
              scheme: scheme,
            ),
          ],

          // Description
          if (desc != null && desc.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle(title: 'Sobre este destino', scheme: scheme),
            const SizedBox(height: 8),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: scheme.onSurface.withAlpha(200),
                height: 1.6,
              ),
            ),
          ],

          // AI Tips
          const SizedBox(height: 28),
          _AiTipsSection(
            store: store,
            scheme: scheme,
            isDark: isDark,
          ),

          // Map
          const SizedBox(height: 28),
          _SectionTitle(title: 'Ubicación', scheme: scheme),
          const SizedBox(height: 12),
          Observer(
            builder: (_) => DestinationMap(
              latitude: destination.latitude,
              longitude: destination.longitude,
              nearbyPois: store.nearbyPois.toList(),
            ),
          ),

          // Nearby POIs (OTM)
          const SizedBox(height: 24),
          NearbyPoisSection(
            store: store,
            destinationXid: destination.xid,
            latitude: destination.latitude,
            longitude: destination.longitude,
          ),
        ],
      ),
    );
  }
}

// AI Tips section

class _AiTipsSection extends StatelessWidget {
  const _AiTipsSection({
    required this.store,
    required this.scheme,
    required this.isDark,
  });

  final DestinationStore store;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final tips = store.aiTips;
        final isLoading = store.isLoadingTips;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? scheme.primary.withAlpha(30)
                : scheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.primary.withAlpha(60),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    'Tips de viaje con IA',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (tips != null && tips.isNotEmpty)
                Text(
                  tips,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: scheme.onSurface.withAlpha(200),
                    height: 1.6,
                  ),
                )
              else if (isLoading)
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Generando con Gemini…',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: scheme.onSurface.withAlpha(150),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              else ...[
                Text(
                  'Genera consejos personalizados para este destino.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: scheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: store.loadAiTips,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    'Generar tips',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Reusable helpers

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.scheme});

  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.scheme,
  });

  final IconData icon;
  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: scheme.onSurface.withAlpha(180),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
