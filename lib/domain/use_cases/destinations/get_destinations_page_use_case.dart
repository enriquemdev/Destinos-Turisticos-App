import '../../dtos/destinations/destination_page_result_dto.dart';
import '../../repositories/destinations_repository.dart';

class GetDestinationsPageUseCase {
  GetDestinationsPageUseCase(this._repository);

  final DestinationsRepository _repository;

  Future<DestinationPageResultDto> call(int page) =>
      _repository.getDestinationsPage(page);
}
