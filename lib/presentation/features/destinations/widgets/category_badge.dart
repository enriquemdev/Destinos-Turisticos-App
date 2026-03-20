import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Category-specific badge with color-coding.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.category,
    this.onDark = true,
  });

  final String category;
  final bool onDark;

  static const Map<String, (String label, Color color, IconData icon)>
      _categoryMeta = {
    'naturaleza': ('Naturaleza', Color(0xFF2E7D32), Icons.forest_rounded),
    'cultura': ('Cultura', Color(0xFF6A1B9A), Icons.museum_rounded),
    'historia': ('Historia', Color(0xFF4E342E), Icons.account_balance_rounded),
    'playa': ('Playa', Color(0xFF0277BD), Icons.beach_access_rounded),
    'aventura': ('Aventura', Color(0xFFE65100), Icons.hiking_rounded),
    'gastronomia': ('Gastronomía', Color(0xFFC62828), Icons.restaurant_rounded),
    'ciudad': ('Ciudad', Color(0xFF37474F), Icons.location_city_rounded),
  };

  static (String, Color, IconData) _meta(String category) {
    final key = category.toLowerCase().trim();
    return _categoryMeta[key] ??
        ('Lugar', const Color(0xFF00897B), Icons.place_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _meta(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: onDark ? color.withAlpha(200) : color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: onDark ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: onDark ? Colors.white : color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
