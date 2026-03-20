import '../../../app/constants/app_constants.dart';
import '../data/models/destination_model.dart';

/// One page of destinations plus whether more can still be loaded.
///
/// [hasMore] is false only when [items] is empty, or when [items] is a
/// partial page while offline (no further Gemini batches possible).
class DestinationsPageLoadResult {
  const DestinationsPageLoadResult({
    required this.items,
    required this.hasMore,
  });

  final List<Destination> items;
  final bool hasMore;
}

/// Whether the "load more" button should be shown after loading [items].
///
/// - totalCount >= [maxDestinations] ⇒ false (hard cap reached).
/// - Empty page ⇒ false.
/// - Full page ⇒ true (more local rows likely exist).
/// - Partial page + online ⇒ true (can ask Gemini for more).
/// - Partial page + offline + totalCount < [maxDestinations] ⇒ true
///   (don't hide button too early; just stop fetching until online).
/// - Partial page + offline + totalCount >= [maxDestinations] ⇒ false.
bool computeDestinationsHasMore(
  List<Destination> items, {
  required bool online,
  required int totalCount,
}) {
  if (totalCount >= maxDestinations) return false;
  if (items.isEmpty) return totalCount < maxDestinations;
  if (items.length >= pageSize) return true;
  if (online) return true;
  return totalCount < maxDestinations;
}
