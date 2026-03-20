import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:destinos_turisticos_app/features/destinations/data/datasources/wikimedia_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late WikimediaDataSource dataSource;
  late MockDio mockNominatimDio;
  late MockDio mockWikidataDio;

  setUpAll(() {
    dotenv.loadFromString(
      envString: 'WIKIDATA_USER_AGENT=test_agent\nGEMINI_API_KEY=test',
    );
  });

  setUp(() {
    mockNominatimDio = MockDio();
    mockWikidataDio = MockDio();
    dataSource = WikimediaDataSource(
      nominatimDio: mockNominatimDio,
      wikidataDio: mockWikidataDio,
    );
  });

  group('WikimediaDataSource Tests', () {
    test(
      'Test 3: fetchImageUrl extracts the correct URL from a standard Wikipedia API response',
      () async {
        const destName = 'León';
        const lat = 12.4333;
        const lon = -86.8833;

        when(
          () => mockNominatimDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: [
              {
                'extratags': {'wikidata': 'Q185567'},
              },
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: 'search'),
          ),
        );

        when(
          () => mockWikidataDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            data: {
              'entities': {
                'Q185567': {
                  'claims': {
                    'P18': [
                      {
                        'mainsnak': {
                          'datavalue': {'value': 'Cathedral of Leon.jpg'},
                        },
                      },
                    ],
                  },
                },
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api.php'),
          ),
        );

        final url = await dataSource.fetchImageUrl(destName, lat, lon);

        expect(
          url,
          'https://commons.wikimedia.org/wiki/Special:FilePath/Cathedral_of_Leon.jpg?width=640',
        );

        verify(
          () => mockNominatimDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).called(1);
        verify(
          () => mockWikidataDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).called(1);
      },
    );
  });
}
