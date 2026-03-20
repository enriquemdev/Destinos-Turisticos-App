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

    // Image sync tests

    test(
      'Test: updateDestinationImage buffers update when list is empty',
      () {
        store.updateDestinationImage('gem_leon', 'https://example.com/leon.jpg');

        // List is empty, so the update should be buffered (not thrown away).
        // Once the list is populated the image should appear.
        final fakeItem = const DestinationDto(
          xid: 'gem_leon',
          name: 'León',
          category: 'ciudad',
          latitude: 12,
          longitude: -86,
          createdAt: 1,
        );
        when(() => mockGetPage(0)).thenAnswer(
          (_) async => DestinationPageResultDto(
            items: [fakeItem],
            hasMore: false,
          ),
        );

        // loadDestinations should apply the buffered update.
        return store.loadDestinations().then((_) {
          expect(
            store.destinations.first.imageUrl,
            'https://example.com/leon.jpg',
          );
        });
      },
    );

    test(
      'Test: updateDestinationImage with existing item updates imageUrl immediately',
      () {
        store.destinations.add(
          const DestinationDto(
            xid: 'gem_granada',
            name: 'Granada',
            category: 'ciudad',
            latitude: 11.9,
            longitude: -85.9,
            createdAt: 1,
          ),
        );

        store.updateDestinationImage(
            'gem_granada', 'https://example.com/granada.jpg');

        expect(
          store.destinations.first.imageUrl,
          'https://example.com/granada.jpg',
        );
      },
    );

    test(
      'Test: updateDestinationImage with unknown xid buffers and is applied on next load',
      () async {
        // Buffer for an xid not in the list yet.
        store.updateDestinationImage('gem_unknown', 'https://example.com/x.jpg');

        final fakeItem = const DestinationDto(
          xid: 'gem_unknown',
          name: 'Unknown',
          category: 'naturaleza',
          latitude: 13.0,
          longitude: -86.0,
          createdAt: 2,
        );
        when(() => mockGetPage(0)).thenAnswer(
          (_) async => DestinationPageResultDto(
            items: [fakeItem],
            hasMore: false,
          ),
        );

        await store.loadDestinations();

        expect(
          store.destinations.first.imageUrl,
          'https://example.com/x.jpg',
        );
      },
    );

    test(
      'Test: syncDestinationFromDetail updates imageUrl in list when it differs',
      () {
        store.destinations.add(
          const DestinationDto(
            xid: 'gem_masaya',
            name: 'Masaya',
            category: 'ciudad',
            latitude: 11.97,
            longitude: -86.09,
            createdAt: 3,
          ),
        );

        final detailVersion = const DestinationDto(
          xid: 'gem_masaya',
          name: 'Masaya',
          category: 'ciudad',
          latitude: 11.97,
          longitude: -86.09,
          imageUrl: 'https://example.com/masaya.jpg',
          createdAt: 3,
        );

        store.syncDestinationFromDetail(detailVersion);

        expect(
          store.destinations.first.imageUrl,
          'https://example.com/masaya.jpg',
        );
      },
    );

    test(
      'Test: syncDestinationFromDetail does not mutate list when imageUrl is unchanged',
      () {
        const original = DestinationDto(
          xid: 'gem_ometepe',
          name: 'Ometepe',
          category: 'naturaleza',
          latitude: 11.5,
          longitude: -85.6,
          imageUrl: 'https://example.com/ometepe.jpg',
          createdAt: 4,
        );
        store.destinations.add(original);

        store.syncDestinationFromDetail(original);

        expect(store.destinations.first, same(original));
      },
    );

    // ── End image sync tests ──────────────────────────────────────────────────

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
