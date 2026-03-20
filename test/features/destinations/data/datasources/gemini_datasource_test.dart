import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:destinos_turisticos_app/data/datasources/remote/gemini_data_source.dart';
import 'package:destinos_turisticos_app/data/models/destinations/gemini_destination_api_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late GeminiDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = GeminiDataSource(dio: mockDio);
  });

  group('GeminiDataSource Tests', () {
    setUpAll(() {
      dotenv.loadFromString(envString: 'GEMINI_API_KEY=test_key');
      registerFallbackValue(RequestOptions(path: ''));
    });

    test(
      'Test 1: fetchBatch successfully parses a valid JSON array into GeminiDestinationApiModel objects',
      () async {
        final validJsonResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': '''
[
  {
    "name": "Volcán Masaya",
    "description": "Un volcán activo impresionante.",
    "category": "naturaleza",
    "highlight": "Mira la lava fundida.",
    "latitude": 11.9833,
    "longitude": -86.1667,
    "address": "Masaya, Nicaragua"
  }
]
''',
                  },
                ],
              },
            },
          ],
        };

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: validJsonResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'generateContent'),
          ),
        );

        final result = await dataSource.fetchBatch([]);

        expect(result, isA<List<GeminiDestinationApiModel>>());
        expect(result.length, 1);
        expect(result.first.name, 'Volcán Masaya');
        expect(result.first.category, 'naturaleza');
        expect(result.first.latitude, 11.9833);

        verify(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            data: any(named: 'data'),
          ),
        ).called(1);
      },
    );

    test(
      'Test 2: fetchBatch throws a GeminiDataSourceException on API failure',
      () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            data: any(named: 'data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'generateContent'),
            response: Response(
              statusCode: 429,
              requestOptions: RequestOptions(path: 'generateContent'),
            ),
            message: 'Límite de solicitudes alcanzado',
          ),
        );

        expect(
          () => dataSource.fetchBatch([]),
          throwsA(isA<GeminiDataSourceException>()),
        );
      },
    );

    test(
      'Test 2b: fetchBatch returns empty list on invalid JSON inside a valid network response',
      () async {
        final invalidJsonResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Esto no es JSON válido'},
                ],
              },
            },
          ],
        };

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: invalidJsonResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'generateContent'),
          ),
        );

        final result = await dataSource.fetchBatch([]);

        expect(result, isEmpty);
      },
    );
  });
}
