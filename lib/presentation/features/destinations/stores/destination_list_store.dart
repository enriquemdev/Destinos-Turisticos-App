import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../../../domain/dtos/destinations/destination_dto.dart';
import '../../../../domain/use_cases/destinations/get_destinations_page_use_case.dart';
import '../../../../domain/use_cases/destinations/search_destinations_use_case.dart';

part 'destination_list_store.g.dart';

class DestinationListStore = DestinationListStoreBase
    with _$DestinationListStore;

abstract class DestinationListStoreBase with Store {
  DestinationListStoreBase({
    required GetDestinationsPageUseCase getDestinationsPage,
    required SearchDestinationsUseCase searchDestinations,
  })  : _getDestinationsPage = getDestinationsPage,
        _searchDestinations = searchDestinations;

  final GetDestinationsPageUseCase _getDestinationsPage;
  final SearchDestinationsUseCase _searchDestinations;

  /// Buffer for image updates that arrive before the list is populated.
  /// Keyed by xid, value is the imageUrl.
  final Map<String, String> _pendingImageUpdates = {};

  // List & Pagination

  @observable
  ObservableList<DestinationDto> destinations =
      ObservableList<DestinationDto>();

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

  // Search

  @observable
  String searchQuery = '';

  @observable
  bool isSearchingWithAi = false;

  // Computed

  @computed
  bool get isSearchActive => searchQuery.isNotEmpty;

  @computed
  List<DestinationDto> get displayedDestinations {
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
      final result = await _getDestinationsPage(0);
      runInAction(() {
        destinations = ObservableList<DestinationDto>.of(result.items);
        currentPage = 0;
        hasMorePages = result.hasMore;
        isLoading = false;
        _applyPendingImageUpdates();
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreItems() async {
    if (isLoadingMore || !hasMorePages || isSearchActive) {
      debugPrint(
        '[ListStore] fetchMoreItems: skipped (isLoadingMore=$isLoadingMore '
        'hasMorePages=$hasMorePages isSearchActive=$isSearchActive)',
      );
      return;
    }

    debugPrint('[ListStore] fetchMoreItems: requesting page=${currentPage + 1}');
    runInAction(() => isLoadingMore = true);
    await Future<void>.delayed(Duration.zero);

    try {
      final nextPage = currentPage + 1;
      final result = await _getDestinationsPage(nextPage);

      runInAction(() {
        if (result.items.isNotEmpty) {
          destinations.addAll(result.items);
          currentPage = nextPage;
        }
        hasMorePages = result.hasMore;
        isLoadingMore = false;
        _applyPendingImageUpdates();
        debugPrint(
          '[ListStore] fetchMoreItems: got ${result.items.length} items '
          'hasMore=${result.hasMore} → totalDestinations=${destinations.length}',
        );
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isLoadingMore = false;
        hasMorePages = false;
      });
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

  @action
  Future<void> searchWithAi() async {
    final query = searchQuery.trim();
    if (query.isEmpty || isSearchingWithAi) return;

    runInAction(() => isSearchingWithAi = true);

    try {
      final results = await _searchDestinations(query);
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
    } else {
      // List is not yet populated (or this xid is on a future page); buffer
      // the update so it is applied once the list has the destination.
      _pendingImageUpdates[xid] = imageUrl;
    }
  }

  /// Applies any buffered image updates to the current destinations list.
  /// Must be called inside a MobX action (already guaranteed at call sites).
  void _applyPendingImageUpdates() {
    if (_pendingImageUpdates.isEmpty) return;
    for (var i = 0; i < destinations.length; i++) {
      final pending = _pendingImageUpdates[destinations[i].xid];
      if (pending != null) {
        destinations[i] = destinations[i].copyWith(imageUrl: pending);
        _pendingImageUpdates.remove(destinations[i].xid);
      }
    }
  }

  // Actions: Detail sync

  @action
  void syncDestinationFromDetail(DestinationDto updated) {
    final idx = destinations.indexWhere((d) => d.xid == updated.xid);
    if (idx != -1 && destinations[idx].imageUrl != updated.imageUrl) {
      destinations[idx] = destinations[idx].copyWith(imageUrl: updated.imageUrl);
    }
  }
}
