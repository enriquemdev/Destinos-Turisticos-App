import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:destinos_turisticos_app/features/destinations/presentation/widgets/offline_banner.dart';

void main() {
  testWidgets('OfflineBanner shows nested content', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OfflineBanner(
          child: Scaffold(
            body: Center(child: Text('inner')),
          ),
        ),
      ),
    );

    expect(find.text('inner'), findsOneWidget);
  });
}
