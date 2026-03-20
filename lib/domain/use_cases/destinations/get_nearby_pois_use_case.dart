import '../../dtos/destinations/nearby_poi_dto.dart';
import '../../repositories/destinations_repository.dart';

class GetNearbyPoisUseCase {
  GetNearbyPoisUseCase(this._repository);

  final DestinationsRepository _repository;

  Future<List<NearbyPoiDto>> call(
    String destinationXid,
    double lat,
    double lon,
  ) =>
      _repository.getNearbyPois(destinationXid, lat, lon);
}
