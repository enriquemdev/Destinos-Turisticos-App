import 'package:get_it/get_it.dart';

import '../features/destinations/data/datasources/gemini_datasource.dart';
import '../features/destinations/data/datasources/local_datasource.dart';
import '../features/destinations/data/datasources/remote_datasource.dart';
import '../features/destinations/data/datasources/wikimedia_datasource.dart';
import '../features/destinations/data/repository/destination_repository.dart';
import '../features/destinations/domain/repositories/i_destination_repository.dart';
import '../features/destinations/presentation/stores/destination_detail_store.dart';
import '../features/destinations/presentation/stores/destination_list_store.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDi() async {
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<DestinationsRemoteDataSource>(
    () => DestinationsRemoteDataSource(),
  );
  sl.registerLazySingleton<GeminiDataSource>(
    () => GeminiDataSource(),
  );
  sl.registerLazySingleton<WikimediaDataSource>(
    () => WikimediaDataSource(),
  );
  sl.registerLazySingleton<DestinationRepository>(
    () => DestinationRepository(
      local: sl<DatabaseHelper>(),
      remote: sl<DestinationsRemoteDataSource>(),
      gemini: sl<GeminiDataSource>(),
      wikimedia: sl<WikimediaDataSource>(),
    ),
  );
  sl.registerLazySingleton<IDestinationRepository>(
    () => sl<DestinationRepository>(),
  );
  sl.registerLazySingleton<DestinationListStore>(
    () {
      final repo = sl<DestinationRepository>();
      final store = DestinationListStore(repository: repo);
      repo.onImageEnriched = store.updateDestinationImage;
      return store;
    },
  );
  sl.registerLazySingleton<DestinationDetailStore>(
    () => DestinationDetailStore(repository: sl<IDestinationRepository>()),
  );

  await sl<DatabaseHelper>().init();
}
