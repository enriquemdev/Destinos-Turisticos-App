import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:destinos_turisticos_app/features/destinations/presentation/pages/list_page.dart';
import 'package:destinos_turisticos_app/features/destinations/presentation/stores/destination_list_store.dart';
import 'package:destinos_turisticos_app/features/destinations/domain/repositories/i_destination_repository.dart';
import 'package:destinos_turisticos_app/features/destinations/data/models/destination_model.dart';
import 'package:destinos_turisticos_app/features/destinations/domain/destination_page_result.dart';
import 'package:destinos_turisticos_app/features/destinations/presentation/widgets/destination_card.dart';
import 'package:destinos_turisticos_app/features/destinations/presentation/widgets/destination_skeleton.dart';

class MockDestinationRepository extends Mock
    implements IDestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late DestinationListStore store;

  setUpAll(() {
    registerFallbackValue(0);
  });

  setUp(() async {
    mockRepository = MockDestinationRepository();
    store = DestinationListStore(repository: mockRepository);

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
        final completer = Completer<DestinationsPageLoadResult>();
        when(
          () => mockRepository.getDestinationsPage(any()),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildTestWidget());

        await tester.pump();

        expect(find.byType(DestinationListSkeleton), findsOneWidget);
        expect(find.byType(DestinationCard), findsNothing);

        completer.complete(
          const DestinationsPageLoadResult(items: [], hasMore: false),
        );
      },
    );

    testWidgets(
      'Test 10: Verify that ListPage successfully renders a list of DestinationCard widgets when loaded',
      (tester) async {
        final fakeItems = [
          Destination(
            xid: '1',
            name: 'Granada',
            category: 'ciudad',
            latitude: 11,
            longitude: -85,
            createdAt: 1,
          ),
          Destination(
            xid: '2',
            name: 'Leon',
            category: 'ciudad',
            latitude: 12,
            longitude: -86,
            createdAt: 2,
          ),
        ];

        when(() => mockRepository.getDestinationsPage(any())).thenAnswer(
          (_) async =>
              DestinationsPageLoadResult(items: fakeItems, hasMore: false),
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
