import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/destination_model.dart';
import '../stores/destination_detail_store.dart';
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
  final DestinationDetailStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
