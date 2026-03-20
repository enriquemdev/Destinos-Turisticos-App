import '../../dtos/destinations/destination_dto.dart';
import '../../repositories/destinations_repository.dart';

class SearchDestinationsUseCase {
  SearchDestinationsUseCase(this._repository);

  final DestinationsRepository _repository;

  Future<List<DestinationDto>> call(String query) =>
      _repository.searchDestinations(query);
}
