import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:destinos_turisticos_app/presentation/features/destinations/pages/list_page.dart';
import 'package:destinos_turisticos_app/presentation/features/destinations/stores/destination_list_store.dart';
import 'package:destinos_turisticos_app/presentation/features/destinations/widgets/destination_card.dart';
import 'package:destinos_turisticos_app/presentation/features/destinations/widgets/destination_skeleton.dart';
import 'package:destinos_turisticos_app/domain/use_cases/destinations/get_destinations_page_use_case.dart';
import 'package:destinos_turisticos_app/domain/use_cases/destinations/search_destinations_use_case.dart';
import 'package:destinos_turisticos_app/domain/dtos/destinations/destination_dto.dart';
import 'package:destinos_turisticos_app/domain/dtos/destinations/destination_page_result_dto.dart';

class MockGetDestinationsPageUseCase extends Mock
    implements GetDestinationsPageUseCase {}

class MockSearchDestinationsUseCase extends Mock
    implements SearchDestinationsUseCase {}

void main() {
  late MockGetDestinationsPageUseCase mockGetPage;
  late MockSearchDestinationsUseCase mockSearch;
  late DestinationListStore store;

  setUpAll(() {
    registerFallbackValue(0);
  });

  setUp(() async {
    mockGetPage = MockGetDestinationsPageUseCase();
    mockSearch = MockSearchDestinationsUseCase();
    store = DestinationListStore(
      getDestinationsPage: mockGetPage,
      searchDestinations: mockSearch,
    );

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<DestinationListStore>(store);
  });

  Widget buildTestWidget() {
    return MaterialApp(home: const ListPage());
  }

  group('ListPage Widget Tests', () {
    testWidgets(
      'Test 9: Verify that ListPage shows DestinationListSkeleton while store is loading',
      (tester) async {
        final completer = Completer<DestinationPageResultDto>();
        when(
          () => mockGetPage(any()),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildTestWidget());

        await tester.pump();

        expect(find.byType(DestinationListSkeleton), findsOneWidget);
        expect(find.byType(DestinationCard), findsNothing);

        completer.complete(
          const DestinationPageResultDto(items: [], hasMore: false),
        );
      },
    );

    testWidgets(
      'Test 10: Verify that ListPage successfully renders a list of DestinationCard widgets when loaded',
      (tester) async {
        final fakeItems = [
          const DestinationDto(
            xid: '1',
            name: 'Granada',
            category: 'ciudad',
            latitude: 11,
            longitude: -85,
            createdAt: 1,
          ),
          const DestinationDto(
            xid: '2',
            name: 'Leon',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 2,
          ),
        ];

        when(() => mockGetPage(any())).thenAnswer(
          (_) async =>
              DestinationPageResultDto(items: fakeItems, hasMore: false),
        );

        await tester.pumpWidget(buildTestWidget());

        await tester.pump();

        await tester.pumpAndSettle();

        expect(find.byType(DestinationListSkeleton), findsNothing);
        expect(find.byType(DestinationCard), findsNWidgets(2));
        expect(find.text('Granada'), findsOneWidget);
        expect(find.text('Leon'), findsOneWidget);
      },
    );
  });
}
