// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DestinationListStore on DestinationListStoreBase, Store {
  Computed<bool>? _$isSearchActiveComputed;

  @override
  bool get isSearchActive => (_$isSearchActiveComputed ??= Computed<bool>(
    () => super.isSearchActive,
    name: 'DestinationListStoreBase.isSearchActive',
  )).value;
  Computed<List<Destination>>? _$displayedDestinationsComputed;

  @override
  List<Destination> get displayedDestinations =>
      (_$displayedDestinationsComputed ??= Computed<List<Destination>>(
        () => super.displayedDestinations,
        name: 'DestinationListStoreBase.displayedDestinations',
      )).value;
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??= Computed<bool>(
    () => super.hasError,
    name: 'DestinationListStoreBase.hasError',
  )).value;

  late final _$destinationsAtom = Atom(
    name: 'DestinationListStoreBase.destinations',
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
    name: 'DestinationListStoreBase.isLoading',
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
    name: 'DestinationListStoreBase.isLoadingMore',
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
    name: 'DestinationListStoreBase.hasMorePages',
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
    name: 'DestinationListStoreBase.currentPage',
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
    name: 'DestinationListStoreBase.errorMessage',
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

  late final _$searchQueryAtom = Atom(
    name: 'DestinationListStoreBase.searchQuery',
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

  late final _$isSearchingWithAiAtom = Atom(
    name: 'DestinationListStoreBase.isSearchingWithAi',
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

  late final _$loadDestinationsAsyncAction = AsyncAction(
    'DestinationListStoreBase.loadDestinations',
    context: context,
  );

  @override
  Future<void> loadDestinations() {
    return _$loadDestinationsAsyncAction.run(() => super.loadDestinations());
  }

  late final _$searchWithAiAsyncAction = AsyncAction(
    'DestinationListStoreBase.searchWithAi',
    context: context,
  );

  @override
  Future<void> searchWithAi() {
    return _$searchWithAiAsyncAction.run(() => super.searchWithAi());
  }

  late final _$DestinationListStoreBaseActionController = ActionController(
    name: 'DestinationListStoreBase',
    context: context,
  );

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$DestinationListStoreBaseActionController.startAction(
      name: 'DestinationListStoreBase.setSearchQuery',
    );
    try {
      return super.setSearchQuery(query);
    } finally {
      _$DestinationListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSearch() {
    final _$actionInfo = _$DestinationListStoreBaseActionController.startAction(
      name: 'DestinationListStoreBase.clearSearch',
    );
    try {
      return super.clearSearch();
    } finally {
      _$DestinationListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDestinationImage(String xid, String imageUrl) {
    final _$actionInfo = _$DestinationListStoreBaseActionController.startAction(
      name: 'DestinationListStoreBase.updateDestinationImage',
    );
    try {
      return super.updateDestinationImage(xid, imageUrl);
    } finally {
      _$DestinationListStoreBaseActionController.endAction(_$actionInfo);
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
searchQuery: ${searchQuery},
isSearchingWithAi: ${isSearchingWithAi},
isSearchActive: ${isSearchActive},
displayedDestinations: ${displayedDestinations},
hasError: ${hasError}
    ''';
  }
}
