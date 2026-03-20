// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DestinationDetailStore on DestinationDetailStoreBase, Store {
  late final _$selectedDestinationAtom = Atom(
    name: 'DestinationDetailStoreBase.selectedDestination',
    context: context,
  );

  @override
  DestinationDto? get selectedDestination {
    _$selectedDestinationAtom.reportRead();
    return super.selectedDestination;
  }

  @override
  set selectedDestination(DestinationDto? value) {
    _$selectedDestinationAtom.reportWrite(value, super.selectedDestination, () {
      super.selectedDestination = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'DestinationDetailStoreBase.isLoading',
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
    name: 'DestinationDetailStoreBase.errorMessage',
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

  late final _$nearbyPoisAtom = Atom(
    name: 'DestinationDetailStoreBase.nearbyPois',
    context: context,
  );

  @override
  ObservableList<NearbyPoiDto> get nearbyPois {
    _$nearbyPoisAtom.reportRead();
    return super.nearbyPois;
  }

  @override
  set nearbyPois(ObservableList<NearbyPoiDto> value) {
    _$nearbyPoisAtom.reportWrite(value, super.nearbyPois, () {
      super.nearbyPois = value;
    });
  }

  late final _$isLoadingNearbyAtom = Atom(
    name: 'DestinationDetailStoreBase.isLoadingNearby',
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

  late final _$loadDestinationByIdAsyncAction = AsyncAction(
    'DestinationDetailStoreBase.loadDestinationById',
    context: context,
  );

  @override
  Future<void> loadDestinationById(String xid) {
    return _$loadDestinationByIdAsyncAction.run(
      () => super.loadDestinationById(xid),
    );
  }

  late final _$loadNearbyPoisAsyncAction = AsyncAction(
    'DestinationDetailStoreBase.loadNearbyPois',
    context: context,
  );

  @override
  Future<void> loadNearbyPois(String destinationXid, double lat, double lon) {
    return _$loadNearbyPoisAsyncAction.run(
      () => super.loadNearbyPois(destinationXid, lat, lon),
    );
  }

  late final _$DestinationDetailStoreBaseActionController = ActionController(
    name: 'DestinationDetailStoreBase',
    context: context,
  );

  @override
  void clearSelectedDestination() {
    final _$actionInfo = _$DestinationDetailStoreBaseActionController
        .startAction(
          name: 'DestinationDetailStoreBase.clearSelectedDestination',
        );
    try {
      return super.clearSelectedDestination();
    } finally {
      _$DestinationDetailStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedDestination: ${selectedDestination},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
nearbyPois: ${nearbyPois},
isLoadingNearby: ${isLoadingNearby}
    ''';
  }
}
