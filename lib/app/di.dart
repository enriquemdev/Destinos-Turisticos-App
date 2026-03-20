import 'package:get_it/get_it.dart';

import '../data/datasources/local/destinations_local_data_source.dart';
import '../data/datasources/remote/destinations_remote_data_source.dart';
import '../data/datasources/remote/gemini_data_source.dart';
import '../data/datasources/remote/wikimedia_data_source.dart';
import '../data/repositories_impl/destinations_repository_impl.dart';
import '../domain/repositories/destinations_repository.dart';
import '../domain/use_cases/destinations/get_destination_by_id_use_case.dart';
import '../domain/use_cases/destinations/get_destinations_page_use_case.dart';
import '../domain/use_cases/destinations/get_nearby_pois_use_case.dart';
import '../domain/use_cases/destinations/search_destinations_use_case.dart';
import '../presentation/features/destinations/stores/destination_detail_store.dart';
import '../presentation/features/destinations/stores/destination_list_store.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDi() async {
  // DataSources
  sl.registerLazySingleton<DestinationsLocalDataSource>(
    () => DestinationsLocalDataSource(),
  );
  sl.registerLazySingleton<DestinationsRemoteDataSource>(
    () => DestinationsRemoteDataSource(),
  );
  sl.registerLazySingleton<GeminiDataSource>(
    () => GeminiDataSource(),
  );
  sl.registerLazySingleton<WikimediaDataSource>(
    () => WikimediaDataSource(),
  );

  // Repository
  sl.registerLazySingleton<DestinationsRepository>(
    () => DestinationsRepositoryImpl(
      local: sl<DestinationsLocalDataSource>(),
      remote: sl<DestinationsRemoteDataSource>(),
      gemini: sl<GeminiDataSource>(),
      wikimedia: sl<WikimediaDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetDestinationsPageUseCase>(
    () => GetDestinationsPageUseCase(sl<DestinationsRepository>()),
  );
  sl.registerLazySingleton<GetDestinationByIdUseCase>(
    () => GetDestinationByIdUseCase(sl<DestinationsRepository>()),
  );
  sl.registerLazySingleton<GetNearbyPoisUseCase>(
    () => GetNearbyPoisUseCase(sl<DestinationsRepository>()),
  );
  sl.registerLazySingleton<SearchDestinationsUseCase>(
    () => SearchDestinationsUseCase(sl<DestinationsRepository>()),
  );

  // Stores
  sl.registerLazySingleton<DestinationListStore>(
    () {
      final repo = sl<DestinationsRepository>();
      final store = DestinationListStore(
        getDestinationsPage: sl<GetDestinationsPageUseCase>(),
        searchDestinations: sl<SearchDestinationsUseCase>(),
      );
      repo.onImageEnriched = store.updateDestinationImage;
      return store;
    },
  );
  sl.registerLazySingleton<DestinationDetailStore>(
    () => DestinationDetailStore(
      getDestinationById: sl<GetDestinationByIdUseCase>(),
      getNearbyPois: sl<GetNearbyPoisUseCase>(),
    ),
  );

  await sl<DestinationsLocalDataSource>().init();
}
