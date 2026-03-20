import '../dtos/destinations/destination_dto.dart';
import '../dtos/destinations/destination_page_result_dto.dart';
import '../dtos/destinations/nearby_poi_dto.dart';

/// Contract for accessing destination data.
///
/// Consumed by use cases. Implemented by [DestinationsRepositoryImpl].
abstract class DestinationsRepository {
  /// Called each time a background image enrichment completes.
  void Function(String xid, String imageUrl)? get onImageEnriched;
  set onImageEnriched(void Function(String xid, String imageUrl)? callback);

  Future<DestinationPageResultDto> getDestinationsPage(int page);

  Future<int> getTotalCount();

  Future<DestinationDto?> getDestinationById(String xid);

  Future<List<NearbyPoiDto>> getNearbyPois(
    String destinationXid,
    double lat,
    double lon,
  );

  Future<List<DestinationDto>> searchDestinations(String query);
}
