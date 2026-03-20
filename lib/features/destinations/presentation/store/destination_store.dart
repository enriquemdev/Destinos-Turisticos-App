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
  bool isSearchingWithAi = false;

  // Computed

  @computed
  bool get isSearchActive => searchQuery.isNotEmpty;

  /// Returns destinations filtered by [searchQuery] (name or description),
  /// or the full list when no query is active.
  @computed
  List<Destination> get displayedDestinations {
    if (searchQuery.isEmpty) return destinations.toList();
    final q = searchQuery.toLowerCase();
    return destinations
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              (d.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
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
    // Disable pagination while searching
    if (isLoadingMore || !hasMorePages || isSearchActive) return;

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
      searchQuery = '';
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
      nearbyPois.clear();
    });
    try {
      final destination = await _repository.getDestinationById(xid);
      runInAction(() {
        selectedDestination = destination;
        if (destination != null && destination.imageUrl != null) {
          final idx = destinations.indexWhere((d) => d.xid == destination.xid);
          if (idx != -1 && destinations[idx].imageUrl != destination.imageUrl) {
            destinations[idx] = destinations[idx].copyWith(
              imageUrl: destination.imageUrl,
            );
          }
        }
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

  // Actions: Search

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  void clearSearch() {
    searchQuery = '';
  }

  /// Calls Gemini to search for up to 5 destinations matching [searchQuery].
  ///
  /// Inserts results into [destinations] (deduped by xid) so the existing
  /// image enrichment callback also covers newly found places.
  @action
  Future<void> searchWithAi() async {
    final query = searchQuery.trim();
    if (query.isEmpty || isSearchingWithAi) return;

    runInAction(() => isSearchingWithAi = true);

    try {
      final results = await _repository.searchDestinations(query);
      runInAction(() {
        for (final result in results) {
          final existingIdx = destinations.indexWhere(
            (d) => d.xid == result.xid,
          );
          if (existingIdx != -1) {
            destinations[existingIdx] = result;
          } else {
            destinations.add(result);
          }
        }
        isSearchingWithAi = false;
      });
    } catch (e) {
      runInAction(() => isSearchingWithAi = false);
    }
  }

  // Actions: Background Image Enrichment

  @action
  void updateDestinationImage(String xid, String imageUrl) {
    final idx = destinations.indexWhere((d) => d.xid == xid);
    if (idx != -1) {
      destinations[idx] = destinations[idx].copyWith(imageUrl: imageUrl);
    }
  }
}
