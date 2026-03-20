import '../../constants/app_constants.dart';
import 'destination_dto.dart';

class DestinationPageResultDto {
  const DestinationPageResultDto({
    required this.items,
    required this.hasMore,
  });

  final List<DestinationDto> items;
  final bool hasMore;
}

/// Whether the "load more" button should be shown after loading [items].
///
/// - totalCount >= [maxDestinations] => false (hard cap reached).
/// - Empty page => false.
/// - Full page => true (more local rows likely exist).
/// - Partial page + online => true (can ask Gemini for more).
/// - Partial page + offline + totalCount < [maxDestinations] => true.
/// - Partial page + offline + totalCount >= [maxDestinations] => false.
bool computeDestinationsHasMore(
  List<DestinationDto> items, {
  required bool online,
  required int totalCount,
}) {
  if (totalCount >= maxDestinations) return false;
  if (items.isEmpty) return totalCount < maxDestinations;
  if (items.length >= pageSize) return true;
  if (online) return true;
  return totalCount < maxDestinations;
}
