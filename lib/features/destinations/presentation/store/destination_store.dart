import 'package:mobx/mobx.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/nearby_poi.dart';
import '../../data/repository/destination_repository.dart';

part 'destination_store.g.dart';

class DestinationStore = DestinationStoreBase with _$DestinationStore;

abstract class DestinationStoreBase with Store {
  DestinationStoreBase({required DestinationRepository repository})
      : _repository = repository;

  final DestinationRepository _repository;

  // List & Pagination

  @observable
  ObservableList<Destination> destinations = ObservableList<Destination>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  bool hasMorePages = true;

  @observable
  int currentPage = 0;

  @observable
  String? errorMessage;

  // Detail

  @observable
  Destination? selectedDestination;

  // Nearby POIs

  @observable
  ObservableList<NearbyPoi> nearbyPois = ObservableList<NearbyPoi>();

  @observable
  bool isLoadingNearby = false;

  // Search

  @observable
  String searchQuery = '';

  @observable
  bool isSearchMode = false;

  @observable
  bool isSearchingWithAi = false;

  @observable
  ObservableList<Destination> searchResults = ObservableList<Destination>();

  // AI Tips

  @observable
  String? aiTips;

  @observable
  bool isLoadingTips = false;

  // Computed

  @computed
  List<Destination> get displayedDestinations {
    if (isSearchMode) return searchResults.toList();
    return destinations.toList();
  }

  @computed
  bool get hasError => errorMessage != null;

  // Actions: List

  @action
  Future<void> loadDestinations() async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
      currentPage = 0;
      hasMorePages = true;
      destinations.clear();
    });
    try {
      final list = await _repository.getDestinationsPage(0);
      runInAction(() {
        destinations = ObservableList<Destination>.of(list);
        currentPage = 0;
        hasMorePages = list.length >= pageSize;
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
  Future<void> fetchMoreItems() async {
    if (isLoadingMore || !hasMorePages || isSearchMode) return;

    runInAction(() => isLoadingMore = true);

    try {
      final nextPage = currentPage + 1;
      final list = await _repository.getDestinationsPage(nextPage);

      runInAction(() {
        if (list.isEmpty) {
          hasMorePages = false;
        } else {
          destinations.addAll(list);
          currentPage = nextPage;
          hasMorePages = list.length >= pageSize;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isLoadingMore = false;
        hasMorePages = false;
      });
    }
  }

  @action
  Future<void> refresh() async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
      isSearchMode = false;
      searchQuery = '';
      searchResults.clear();
    });
    try {
      await _repository.refresh();
      final list = await _repository.getDestinationsPage(0);
      runInAction(() {
        destinations = ObservableList<Destination>.of(list);
        currentPage = 0;
        hasMorePages = list.length >= pageSize;
        isLoading = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Actions: Detail

  @action
  Future<void> loadDestinationById(String xid) async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
      selectedDestination = null;
      aiTips = null;
      nearbyPois.clear();
    });
    try {
      final destination = await _repository.getDestinationById(xid);
      runInAction(() {
        selectedDestination = destination;
        aiTips = destination?.aiTips;
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
    aiTips = null;
    isLoadingTips = false;
    nearbyPois.clear();
    isLoadingNearby = false;
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

  // Actions: AI Tips

  @action
  Future<void> loadAiTips() async {
    final dest = selectedDestination;
    if (dest == null || isLoadingTips) return;

    runInAction(() {
      isLoadingTips = true;
      aiTips = null;
    });
    try {
      final tips = await _repository.getAiTips(dest.xid, dest.name, dest.category);
      runInAction(() {
        aiTips = tips;
        if (tips != null) {
          selectedDestination = dest.copyWith(aiTips: tips);
        }
        isLoadingTips = false;
      });
    } catch (e) {
      runInAction(() => isLoadingTips = false);
    }
  }

  // Actions: Search

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    if (query.trim().isEmpty) exitSearchMode();
  }

  @action
  Future<void> searchDestinations() async {
    final query = searchQuery.trim();
    if (query.isEmpty) return;

    runInAction(() {
      isSearchMode = true;
      isSearchingWithAi = true;
      errorMessage = null;
      searchResults.clear();
    });

    try {
      final results = await _repository.searchDestinations(query);
      runInAction(() {
        searchResults = ObservableList<Destination>.of(results);
        isSearchingWithAi = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isSearchingWithAi = false;
      });
    }
  }

  @action
  void exitSearchMode() {
    isSearchMode = false;
    searchResults.clear();
    searchQuery = '';
  }
}
