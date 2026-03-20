import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../data/models/destination_model.dart';
import '../../domain/repositories/i_destination_repository.dart';

part 'destination_list_store.g.dart';

class DestinationListStore = DestinationListStoreBase with _$DestinationListStore;

abstract class DestinationListStoreBase with Store {
  DestinationListStoreBase({required IDestinationRepository repository})
      : _repository = repository;

  final IDestinationRepository _repository;

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
      final result = await _repository.getDestinationsPage(0);
      runInAction(() {
        destinations = ObservableList<Destination>.of(result.items);
        currentPage = 0;
        hasMorePages = result.hasMore;
        isLoading = false;
      });
    } catch (e) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Not an `@action`: async [AsyncAction] batches notifications until the
  /// [Future] completes, so `isLoadingMore` never paints between true/false.
  Future<void> fetchMoreItems() async {
    // Disable pagination while searching
    if (isLoadingMore || !hasMorePages || isSearchActive) {
      debugPrint(
        '[ListStore] fetchMoreItems: skipped (isLoadingMore=$isLoadingMore '
        'hasMorePages=$hasMorePages isSearchActive=$isSearchActive)',
      );
      return;
    }

    debugPrint('[ListStore] fetchMoreItems: requesting page=${currentPage + 1}');
    runInAction(() => isLoadingMore = true);
    // Let the next frame paint the footer loader before awaiting network/DB.
    await Future<void>.delayed(Duration.zero);

    try {
      final nextPage = currentPage + 1;
      final result = await _repository.getDestinationsPage(nextPage);

      runInAction(() {
        if (result.items.isNotEmpty) {
          destinations.addAll(result.items);
          currentPage = nextPage;
        }
        hasMorePages = result.hasMore;
        isLoadingMore = false;
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
