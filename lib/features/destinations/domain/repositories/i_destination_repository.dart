import '../../data/models/destination_model.dart';
import '../../data/models/nearby_poi.dart';
import '../destination_page_result.dart';

/// Contract for accessing destination data.
///
/// Consumed by stores. Implemented by [DestinationRepository].
abstract interface class IDestinationRepository {
  Future<DestinationsPageLoadResult> getDestinationsPage(int page);

  Future<int> getTotalCount();

  Future<Destination?> getDestinationById(String xid);

  Future<List<NearbyPoi>> getNearbyPois(
    String destinationXid,
    double lat,
    double lon,
  );

  Future<List<Destination>> searchDestinations(String query);
}
