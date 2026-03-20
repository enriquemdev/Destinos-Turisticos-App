import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';

import 'package:destinos_turisticos_app/data/repositories_impl/destinations_repository_impl.dart';
import 'package:destinos_turisticos_app/data/datasources/remote/gemini_data_source.dart';
import 'package:destinos_turisticos_app/data/datasources/local/destinations_local_data_source.dart';
import 'package:destinos_turisticos_app/data/datasources/remote/destinations_remote_data_source.dart';
import 'package:destinos_turisticos_app/data/datasources/remote/wikimedia_data_source.dart';
import 'package:destinos_turisticos_app/data/models/destinations/gemini_destination_api_model.dart';
import 'package:destinos_turisticos_app/domain/dtos/destinations/destination_dto.dart';

class MockDestinationsLocalDataSource extends Mock
    implements DestinationsLocalDataSource {}

class MockDestinationsRemoteDataSource extends Mock
    implements DestinationsRemoteDataSource {}

class MockGeminiDataSource extends Mock implements GeminiDataSource {}

class MockWikimediaDataSource extends Mock implements WikimediaDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DestinationsRepositoryImpl repository;
  late MockDestinationsLocalDataSource mockLocal;
  late MockDestinationsRemoteDataSource mockRemote;
  late MockGeminiDataSource mockGemini;
  late MockWikimediaDataSource mockWikimedia;

  void setConnectivityResult(String result) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') {
              return [result];
            }
            return null;
          },
        );
  }

  setUpAll(() {
    registerFallbackValue(
      const DestinationDto(
        xid: 'dummy',
        name: 'dummy',
        category: 'dummy',
        latitude: 0,
        longitude: 0,
        createdAt: 0,
      ),
    );
    registerFallbackValue(<DestinationDto>[]);
  });

  setUp(() {
    mockLocal = MockDestinationsLocalDataSource();
    mockRemote = MockDestinationsRemoteDataSource();
    mockGemini = MockGeminiDataSource();
    mockWikimedia = MockWikimediaDataSource();

    repository = DestinationsRepositoryImpl(
      local: mockLocal,
      remote: mockRemote,
      gemini: mockGemini,
      wikimedia: mockWikimedia,
    );
  });

  group('DestinationsRepositoryImpl Tests', () {
    test(
      'Test 4: Verify getDestinationsPage behavior when offline (returns local DB data, doesn\'t call Gemini)',
      () async {
        setConnectivityResult('none');

        final mockData = [
          const DestinationDto(
            xid: '1',
            name: 'León',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 1,
          ),
        ];

        when(() => mockLocal.getCount()).thenAnswer((_) async => 1);
        when(
          () => mockLocal.getPage(any(), any()),
        ).thenAnswer((_) async => mockData);

        final result = await repository.getDestinationsPage(0);

        expect(result.items, equals(mockData));
        expect(result.hasMore, isTrue);
        verifyNever(() => mockGemini.fetchBatch(any()));
      },
    );

    test(
      'Test 5: Verify getDestinationsPage behavior when online and DB empty (calls Gemini, saves to local DB)',
      () async {
        setConnectivityResult('wifi');

        final apiModels = [
          const GeminiDestinationApiModel(
            name: 'Masaya',
            description: 'Volcan',
            category: 'naturaleza',
            highlight: 'lava',
            latitude: 12,
            longitude: -86,
            address: '',
          ),
        ];

        when(() => mockLocal.getCount()).thenAnswer((_) async => 0);
        when(() => mockLocal.getAllNames()).thenAnswer((_) async => []);
        when(() => mockGemini.fetchBatch(any()))
            .thenAnswer((_) async => apiModels);
        when(() => mockLocal.insertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.getById(any())).thenAnswer((_) async => null);
        when(
          () => mockWikimedia.fetchImageUrl(any(), any(), any()),
        ).thenAnswer((_) async => 'http://image');
        when(
          () => mockLocal.updateImageUrl(any(), any()),
        ).thenAnswer((_) async {});

        bool isFirstCall = true;
        when(() => mockLocal.getCount()).thenAnswer((_) async {
          if (isFirstCall) {
            isFirstCall = false;
            return 0;
          }
          return 1;
        });

        final savedItems = [
          const DestinationDto(
            xid: 'gem_masaya',
            name: 'Masaya',
            category: 'naturaleza',
            latitude: 12,
            longitude: -86,
            createdAt: 1,
          ),
        ];
        when(
          () => mockLocal.getPage(any(), any()),
        ).thenAnswer((_) async => savedItems);

        final result = await repository.getDestinationsPage(0);

        expect(result.items.first.name, 'Masaya');
        verify(() => mockGemini.fetchBatch([])).called(1);
        verify(() => mockLocal.insertAll(any())).called(1);
      },
    );

    test(
      'Test 6: Verify searchDestinations calls Gemini for AI search and saves results to SQLite',
      () async {
        setConnectivityResult('wifi');
        const query = 'playa';

        final searchModels = [
          const GeminiDestinationApiModel(
            name: 'Playa Maderas',
            description: 'Surf',
            category: 'playa',
            highlight: 'olas',
            latitude: 11,
            longitude: -85,
            address: '',
          ),
        ];

        when(
          () => mockGemini.searchDestinations(query),
        ).thenAnswer((_) async => searchModels);
        when(() => mockLocal.insertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.getById(any())).thenAnswer((_) async => null);
        when(
          () => mockWikimedia.fetchImageUrl(any(), any(), any()),
        ).thenAnswer((_) async => 'http://image');
        when(
          () => mockLocal.updateImageUrl(any(), any()),
        ).thenAnswer((_) async {});

        final results = await repository.searchDestinations(query);

        expect(results.length, 1);
        expect(results.first.name, 'Playa Maderas');
        expect(results.first.xid, startsWith('search_playa_maderas'));

        verify(() => mockGemini.searchDestinations(query)).called(1);
        verify(() => mockLocal.insertAll(any())).called(1);
      },
    );
  });
}
