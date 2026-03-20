import 'package:mobx/mobx.dart';

import '../../../../domain/dtos/destinations/destination_dto.dart';
import '../../../../domain/dtos/destinations/nearby_poi_dto.dart';
import '../../../../domain/use_cases/destinations/get_destination_by_id_use_case.dart';
import '../../../../domain/use_cases/destinations/get_nearby_pois_use_case.dart';

part 'destination_detail_store.g.dart';

class DestinationDetailStore = DestinationDetailStoreBase
    with _$DestinationDetailStore;

abstract class DestinationDetailStoreBase with Store {
  DestinationDetailStoreBase({
    required GetDestinationByIdUseCase getDestinationById,
    required GetNearbyPoisUseCase getNearbyPois,
  })  : _getDestinationById = getDestinationById,
        _getNearbyPois = getNearbyPois;

  final GetDestinationByIdUseCase _getDestinationById;
  final GetNearbyPoisUseCase _getNearbyPois;

  // Detail

  @observable
  DestinationDto? selectedDestination;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // Nearby POIs

  @observable
  ObservableList<NearbyPoiDto> nearbyPois = ObservableList<NearbyPoiDto>();

  @observable
  bool isLoadingNearby = false;

  // Actions: Detail

  @action
  Future<void> loadDestinationById(String xid) async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
      selectedDestination = null;
      nearbyPois.clear();
    });
    try {
      final destination = await _getDestinationById(xid);
      runInAction(() {
        selectedDestination = destination;
        isLoading = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @action
  void clearSelectedDestination() {
    selectedDestination = null;
    nearbyPois.clear();
    isLoadingNearby = false;
    errorMessage = null;
  }

  // Actions: Nearby POIs

  @action
  Future<void> loadNearbyPois(
    String destinationXid,
    double lat,
    double lon,
  ) async {
    if (isLoadingNearby) return;
    runInAction(() {
      isLoadingNearby = true;
      nearbyPois.clear();
    });
    try {
      final pois = await _getNearbyPois(destinationXid, lat, lon);
      runInAction(() {
        nearbyPois = ObservableList<NearbyPoiDto>.of(pois);
        isLoadingNearby = false;
      });
    } catch (e) {
      runInAction(() => isLoadingNearby = false);
    }
  }
}
