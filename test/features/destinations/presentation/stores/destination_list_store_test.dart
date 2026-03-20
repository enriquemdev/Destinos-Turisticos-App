import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:destinos_turisticos_app/presentation/features/destinations/stores/destination_list_store.dart';
import 'package:destinos_turisticos_app/domain/use_cases/destinations/get_destinations_page_use_case.dart';
import 'package:destinos_turisticos_app/domain/use_cases/destinations/search_destinations_use_case.dart';
import 'package:destinos_turisticos_app/domain/dtos/destinations/destination_dto.dart';
import 'package:destinos_turisticos_app/domain/dtos/destinations/destination_page_result_dto.dart';

class MockGetDestinationsPageUseCase extends Mock
    implements GetDestinationsPageUseCase {}

class MockSearchDestinationsUseCase extends Mock
    implements SearchDestinationsUseCase {}

void main() {
  late DestinationListStore store;
  late MockGetDestinationsPageUseCase mockGetPage;
  late MockSearchDestinationsUseCase mockSearch;

  setUpAll(() {
    registerFallbackValue(0);
  });

  setUp(() {
    mockGetPage = MockGetDestinationsPageUseCase();
    mockSearch = MockSearchDestinationsUseCase();
    store = DestinationListStore(
      getDestinationsPage: mockGetPage,
      searchDestinations: mockSearch,
    );
  });

  group('DestinationListStore Tests', () {
    test(
      'Test 7: Verify loadDestinations action correctly toggles isLoading, fetches page, and updates list',
      () async {
        final completer = Completer<DestinationPageResultDto>();
        when(
          () => mockGetPage(0),
        ).thenAnswer((_) => completer.future);

        final fakeItems = [
          const DestinationDto(
            xid: '1',
            name: 'León',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 1,
          ),
        ];
        final fakeResult = DestinationPageResultDto(
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

        verify(() => mockGetPage(0)).called(1);
      },
    );

    test(
      'Test 8: Verify searchWithAi action sets isSearchingWithAi, calls use case, and appends results properly',
      () async {
        store.destinations.add(
          const DestinationDto(
            xid: 'existing',
            name: 'Managua',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 1,
          ),
        );

        store.setSearchQuery('volcan');

        final completer = Completer<List<DestinationDto>>();
        when(
          () => mockSearch('volcan'),
        ).thenAnswer((_) => completer.future);

        final searchResults = [
          const DestinationDto(
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

        verify(() => mockSearch('volcan')).called(1);
      },
    );
  });
}
