import 'package:get_it/get_it.dart';

import '../features/destinations/data/datasources/local_datasource.dart';
import '../features/destinations/data/datasources/remote_datasource.dart';
import '../features/destinations/data/repository/destination_repository.dart';
import '../features/destinations/presentation/store/destination_store.dart';

final GetIt sl = GetIt.instance;

void setupDi() {
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<DestinationsRemoteDataSource>(
    () => DestinationsRemoteDataSource(),
  );
  sl.registerLazySingleton<DestinationRepository>(
    () => DestinationRepository(
      local: sl<DatabaseHelper>(),
      remote: sl<DestinationsRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<DestinationStore>(
    () => DestinationStore(repository: sl<DestinationRepository>()),
  );
}
