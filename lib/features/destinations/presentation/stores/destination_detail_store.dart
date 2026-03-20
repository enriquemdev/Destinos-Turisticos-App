import 'package:mobx/mobx.dart';

import '../../data/models/destination_model.dart';
import '../../data/models/nearby_poi.dart';
import '../../domain/repositories/i_destination_repository.dart';

part 'destination_detail_store.g.dart';

class DestinationDetailStore = DestinationDetailStoreBase with _$DestinationDetailStore;

abstract class DestinationDetailStoreBase with Store {
  DestinationDetailStoreBase({required IDestinationRepository repository})
      : _repository = repository;

  final IDestinationRepository _repository;

  // Detail

  @observable
  Destination? selectedDestination;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // Nearby POIs

  @observable
  ObservableList<NearbyPoi> nearbyPois = ObservableList<NearbyPoi>();

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
      final destination = await _repository.getDestinationById(xid);
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
      final pois = await _repository.getNearbyPois(destinationXid, lat, lon);
      runInAction(() {
        nearbyPois = ObservableList<NearbyPoi>.of(pois);
        isLoadingNearby = false;
      });
    } catch (e) {
      runInAction(() => isLoadingNearby = false);
    }
  }
}
