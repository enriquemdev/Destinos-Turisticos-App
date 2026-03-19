// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DestinationStore on DestinationStoreBase, Store {
  Computed<List<Destination>>? _$filteredDestinationsComputed;

  @override
  List<Destination> get filteredDestinations =>
      (_$filteredDestinationsComputed ??= Computed<List<Destination>>(
        () => super.filteredDestinations,
        name: 'DestinationStoreBase.filteredDestinations',
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

  late final _$loadDestinationsAsyncAction = AsyncAction(
    'DestinationStoreBase.loadDestinations',
    context: context,
  );

  @override
  Future<void> loadDestinations() {
    return _$loadDestinationsAsyncAction.run(() => super.loadDestinations());
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

  late final _$refreshAsyncAction = AsyncAction(
    'DestinationStoreBase.refresh',
    context: context,
  );

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$DestinationStoreBaseActionController = ActionController(
    name: 'DestinationStoreBase',
    context: context,
  );

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
  String toString() {
    return '''
destinations: ${destinations},
selectedDestination: ${selectedDestination},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
filteredDestinations: ${filteredDestinations}
    ''';
  }
}
