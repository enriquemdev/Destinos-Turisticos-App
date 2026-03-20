import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton card shown during initial list loading.
class DestinationCardSkeleton extends StatelessWidget {
  const DestinationCardSkeleton({super.key});

  static const double _cardHeight = 220;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: _cardHeight,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Shows a column of skeleton cards during initial load.
class DestinationListSkeleton extends StatelessWidget {
  const DestinationListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => const DestinationCardSkeleton(),
    );
  }
}
