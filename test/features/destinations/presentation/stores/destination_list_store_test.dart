import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:destinos_turisticos_app/features/destinations/presentation/stores/destination_list_store.dart';
import 'package:destinos_turisticos_app/features/destinations/domain/repositories/i_destination_repository.dart';
import 'package:destinos_turisticos_app/features/destinations/data/models/destination_model.dart';
import 'package:destinos_turisticos_app/features/destinations/domain/destination_page_result.dart';

class MockDestinationRepository extends Mock
    implements IDestinationRepository {}

void main() {
  late DestinationListStore store;
  late MockDestinationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(0);
  });

  setUp(() {
    mockRepository = MockDestinationRepository();
    store = DestinationListStore(repository: mockRepository);
  });

  group('DestinationListStore Tests', () {
    test(
      'Test 7: Verify loadDestinations action correctly toggles isLoading, fetches page, and updates list',
      () async {
        final completer = Completer<DestinationsPageLoadResult>();
        when(
          () => mockRepository.getDestinationsPage(0),
        ).thenAnswer((_) => completer.future);

        final fakeItems = [
          Destination(
            xid: '1',
            name: 'León',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 1,
          ),
        ];
        final fakeResult = DestinationsPageLoadResult(
          items: fakeItems,
          hasMore: true,
        );

        final future = store.loadDestinations();
        expect(store.isLoading, isTrue);

        completer.complete(fakeResult);
        await future;

        expect(store.isLoading, isFalse);
        expect(store.destinations.length, 1);
        expect(store.destinations.first.name, 'León');
        expect(store.hasMorePages, isTrue);
        expect(store.errorMessage, isNull);

        verify(() => mockRepository.getDestinationsPage(0)).called(1);
      },
    );

    test(
      'Test 8: Verify searchWithAi action sets isSearchingWithAi, calls repo, and appends results properly',
      () async {
        store.destinations.add(
          Destination(
            xid: 'existing',
            name: 'Managua',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 1,
          ),
        );

        store.setSearchQuery('volcan');

        final completer = Completer<List<Destination>>();
        when(
          () => mockRepository.searchDestinations('volcan'),
        ).thenAnswer((_) => completer.future);

        final searchResults = [
          Destination(
            xid: 'search_volcan',
            name: 'Volcán Masaya',
            category: 'naturaleza',
            latitude: 11.9,
            longitude: -86.1,
            createdAt: 2,
          ),
        ];

        final future = store.searchWithAi();
        expect(store.isSearchingWithAi, isTrue);

        completer.complete(searchResults);
        await future;

        expect(store.isSearchingWithAi, isFalse);
        expect(store.destinations.length, 2);
        expect(store.destinations.any((d) => d.name == 'Managua'), isTrue);
        expect(
          store.destinations.any((d) => d.name == 'Volcán Masaya'),
          isTrue,
        );

        verify(() => mockRepository.searchDestinations('volcan')).called(1);
      },
    );
  });
}
