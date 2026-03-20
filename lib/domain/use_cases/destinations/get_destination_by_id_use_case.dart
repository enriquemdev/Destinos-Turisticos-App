import '../../dtos/destinations/destination_dto.dart';
import '../../repositories/destinations_repository.dart';

class GetDestinationByIdUseCase {
  GetDestinationByIdUseCase(this._repository);

  final DestinationsRepository _repository;

  Future<DestinationDto?> call(String xid) =>
      _repository.getDestinationById(xid);
}
