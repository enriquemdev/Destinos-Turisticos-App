// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DestinationStore on DestinationStoreBase, Store {
  Computed<List<Destination>>? _$displayedDestinationsComputed;

  @override
  List<Destination> get displayedDestinations =>
      (_$displayedDestinationsComputed ??= Computed<List<Destination>>(
        () => super.displayedDestinations,
        name: 'DestinationStoreBase.displayedDestinations',
      )).value;
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??= Computed<bool>(
    () => super.hasError,
    name: 'DestinationStoreBase.hasError',
  )).value;

  late final _$destinationsAtom = Atom(
    name: 'DestinationStoreBase.destinations',
    context: context,
  );

  @override
  ObservableList<Destination> get destinations {
    _$destinationsAtom.reportRead();
    return super.destinations;
  }

  @override
  set destinations(ObservableList<Destination> value) {
    _$destinationsAtom.reportWrite(value, super.destinations, () {
      super.destinations = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'DestinationStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isLoadingMoreAtom = Atom(
    name: 'DestinationStoreBase.isLoadingMore',
    context: context,
  );

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
    });
  }

  late final _$hasMorePagesAtom = Atom(
    name: 'DestinationStoreBase.hasMorePages',
    context: context,
  );

  @override
  bool get hasMorePages {
    _$hasMorePagesAtom.reportRead();
    return super.hasMorePages;
  }

  @override
  set hasMorePages(bool value) {
    _$hasMorePagesAtom.reportWrite(value, super.hasMorePages, () {
      super.hasMorePages = value;
    });
  }

  late final _$currentPageAtom = Atom(
    name: 'DestinationStoreBase.currentPage',
    context: context,
  );

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'DestinationStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$selectedDestinationAtom = Atom(
    name: 'DestinationStoreBase.selectedDestination',
    context: context,
  );

  @override
  Destination? get selectedDestination {
    _$selectedDestinationAtom.reportRead();
    return super.selectedDestination;
  }

  @override
  set selectedDestination(Destination? value) {
    _$selectedDestinationAtom.reportWrite(value, super.selectedDestination, () {
      super.selectedDestination = value;
    });
  }

  late final _$nearbyPoisAtom = Atom(
    name: 'DestinationStoreBase.nearbyPois',
    context: context,
  );

  @override
  ObservableList<NearbyPoi> get nearbyPois {
    _$nearbyPoisAtom.reportRead();
    return super.nearbyPois;
  }

  @override
  set nearbyPois(ObservableList<NearbyPoi> value) {
    _$nearbyPoisAtom.reportWrite(value, super.nearbyPois, () {
      super.nearbyPois = value;
    });
  }

  late final _$isLoadingNearbyAtom = Atom(
    name: 'DestinationStoreBase.isLoadingNearby',
    context: context,
  );

  @override
  bool get isLoadingNearby {
    _$isLoadingNearbyAtom.reportRead();
    return super.isLoadingNearby;
  }

  @override
  set isLoadingNearby(bool value) {
    _$isLoadingNearbyAtom.reportWrite(value, super.isLoadingNearby, () {
      super.isLoadingNearby = value;
    });
  }

  late final _$searchQueryAtom = Atom(
    name: 'DestinationStoreBase.searchQuery',
    context: context,
  );

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$isSearchModeAtom = Atom(
    name: 'DestinationStoreBase.isSearchMode',
    context: context,
  );

  @override
  bool get isSearchMode {
    _$isSearchModeAtom.reportRead();
    return super.isSearchMode;
  }

  @override
  set isSearchMode(bool value) {
    _$isSearchModeAtom.reportWrite(value, super.isSearchMode, () {
      super.isSearchMode = value;
    });
  }

  late final _$isSearchingWithAiAtom = Atom(
    name: 'DestinationStoreBase.isSearchingWithAi',
    context: context,
  );

  @override
  bool get isSearchingWithAi {
    _$isSearchingWithAiAtom.reportRead();
    return super.isSearchingWithAi;
  }

  @override
  set isSearchingWithAi(bool value) {
    _$isSearchingWithAiAtom.reportWrite(value, super.isSearchingWithAi, () {
      super.isSearchingWithAi = value;
    });
  }

  late final _$searchResultsAtom = Atom(
    name: 'DestinationStoreBase.searchResults',
    context: context,
  );

  @override
  ObservableList<Destination> get searchResults {
    _$searchResultsAtom.reportRead();
    return super.searchResults;
  }

  @override
  set searchResults(ObservableList<Destination> value) {
    _$searchResultsAtom.reportWrite(value, super.searchResults, () {
      super.searchResults = value;
    });
  }

  late final _$aiTipsAtom = Atom(
    name: 'DestinationStoreBase.aiTips',
    context: context,
  );

  @override
  String? get aiTips {
    _$aiTipsAtom.reportRead();
    return super.aiTips;
  }

  @override
  set aiTips(String? value) {
    _$aiTipsAtom.reportWrite(value, super.aiTips, () {
      super.aiTips = value;
    });
  }

  late final _$isLoadingTipsAtom = Atom(
    name: 'DestinationStoreBase.isLoadingTips',
    context: context,
  );

  @override
  bool get isLoadingTips {
    _$isLoadingTipsAtom.reportRead();
    return super.isLoadingTips;
  }

  @override
  set isLoadingTips(bool value) {
    _$isLoadingTipsAtom.reportWrite(value, super.isLoadingTips, () {
      super.isLoadingTips = value;
    });
  }

  late final _$loadDestinationsAsyncAction = AsyncAction(
    'DestinationStoreBase.loadDestinations',
    context: context,
  );

  @override
  Future<void> loadDestinations() {
    return _$loadDestinationsAsyncAction.run(() => super.loadDestinations());
  }

  late final _$fetchMoreItemsAsyncAction = AsyncAction(
    'DestinationStoreBase.fetchMoreItems',
    context: context,
  );

  @override
  Future<void> fetchMoreItems() {
    return _$fetchMoreItemsAsyncAction.run(() => super.fetchMoreItems());
  }

  late final _$refreshAsyncAction = AsyncAction(
    'DestinationStoreBase.refresh',
    context: context,
  );

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$loadDestinationByIdAsyncAction = AsyncAction(
    'DestinationStoreBase.loadDestinationById',
    context: context,
  );

  @override
  Future<void> loadDestinationById(String xid) {
    return _$loadDestinationByIdAsyncAction.run(
      () => super.loadDestinationById(xid),
    );
  }

  late final _$loadNearbyPoisAsyncAction = AsyncAction(
    'DestinationStoreBase.loadNearbyPois',
    context: context,
  );

  @override
  Future<void> loadNearbyPois(String destinationXid, double lat, double lon) {
    return _$loadNearbyPoisAsyncAction.run(
      () => super.loadNearbyPois(destinationXid, lat, lon),
    );
  }

  late final _$loadAiTipsAsyncAction = AsyncAction(
    'DestinationStoreBase.loadAiTips',
    context: context,
  );

  @override
  Future<void> loadAiTips() {
    return _$loadAiTipsAsyncAction.run(() => super.loadAiTips());
  }

  late final _$searchDestinationsAsyncAction = AsyncAction(
    'DestinationStoreBase.searchDestinations',
    context: context,
  );

  @override
  Future<void> searchDestinations() {
    return _$searchDestinationsAsyncAction.run(
      () => super.searchDestinations(),
    );
  }

  late final _$DestinationStoreBaseActionController = ActionController(
    name: 'DestinationStoreBase',
    context: context,
  );

  @override
  void clearSelectedDestination() {
    final _$actionInfo = _$DestinationStoreBaseActionController.startAction(
      name: 'DestinationStoreBase.clearSelectedDestination',
    );
    try {
      return super.clearSelectedDestination();
    } finally {
      _$DestinationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$DestinationStoreBaseActionController.startAction(
      name: 'DestinationStoreBase.setSearchQuery',
    );
    try {
      return super.setSearchQuery(query);
    } finally {
      _$DestinationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void exitSearchMode() {
    final _$actionInfo = _$DestinationStoreBaseActionController.startAction(
      name: 'DestinationStoreBase.exitSearchMode',
    );
    try {
      return super.exitSearchMode();
    } finally {
      _$DestinationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDestinationImage(String xid, String imageUrl) {
    final _$actionInfo = _$DestinationStoreBaseActionController.startAction(
      name: 'DestinationStoreBase.updateDestinationImage',
    );
    try {
      return super.updateDestinationImage(xid, imageUrl);
    } finally {
      _$DestinationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
destinations: ${destinations},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
hasMorePages: ${hasMorePages},
currentPage: ${currentPage},
errorMessage: ${errorMessage},
selectedDestination: ${selectedDestination},
nearbyPois: ${nearbyPois},
isLoadingNearby: ${isLoadingNearby},
searchQuery: ${searchQuery},
isSearchMode: ${isSearchMode},
isSearchingWithAi: ${isSearchingWithAi},
searchResults: ${searchResults},
aiTips: ${aiTips},
isLoadingTips: ${isLoadingTips},
displayedDestinations: ${displayedDestinations},
hasError: ${hasError}
    ''';
  }
}
