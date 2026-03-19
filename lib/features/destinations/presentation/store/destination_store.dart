import 'package:mobx/mobx.dart';

import '../../data/models/destination_model.dart';
import '../../data/repository/destination_repository.dart';

part 'destination_store.g.dart';

class DestinationStore = DestinationStoreBase with _$DestinationStore;

abstract class DestinationStoreBase with Store {
  DestinationStoreBase({required DestinationRepository repository})
      : _repository = repository;

  final DestinationRepository _repository;

  @observable
  ObservableList<Destination> destinations = ObservableList<Destination>();

  @observable
  Destination? selectedDestination;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @computed
  List<Destination> get filteredDestinations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return destinations.toList();
    return destinations
        .where(
          (d) =>
              d.name.toLowerCase().contains(query) ||
              d.category.toLowerCase().contains(query),
        )
        .toList();
  }

  @action
  Future<void> loadDestinations() async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final list = await _repository.getDestinations();
      runInAction(() {
        destinations = ObservableList<Destination>.of(list);
        isLoading = false;
      });
    } catch (e, _) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @action
  Future<void> loadDestinationById(String xid) async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
      selectedDestination = null;
    });
    try {
      final destination = await _repository.getDestinationById(xid);
      runInAction(() {
        selectedDestination = destination;
        isLoading = false;
      });
    } catch (e, _) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @action
  Future<void> refresh() async {
    runInAction(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await _repository.refresh();
      final list = await _repository.getDestinations();
      runInAction(() {
        destinations = ObservableList<Destination>.of(list);
        isLoading = false;
      });
    } catch (e, _) {
      runInAction(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  void clearSelectedDestination() {
    selectedDestination = null;
  }
}
