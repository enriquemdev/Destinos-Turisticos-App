import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';

/// Destination data returned by Gemini (excludes image — resolved via Wikidata).
class GeminiDestinationDto {
  const GeminiDestinationDto({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.highlight,
    required this.address,
  });

  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final String highlight;
  final String address;

  @override
  String toString() => 'GeminiDestinationDto($name)';
}

/// All Gemini interactions: destination batches, AI tips, and smart search.
class GeminiDataSource {
  GeminiDataSource({Dio? dio}) : _dio = dio ?? ApiClient.createGemini();

  final Dio _dio;

  static const String _model = 'models/gemini-2.5-flash-lite';

  // Public API

  /// Returns a batch of 20 Nicaragua tourist destinations excluding [excludeNames].
  Future<List<GeminiDestinationDto>> fetchBatch(
    List<String> excludeNames,
  ) async {
    final exclusion = excludeNames.isNotEmpty
        ? 'Excluye estos destinos que ya tengo: ${excludeNames.join(', ')}.'
        : '';

    final prompt =
        '''
Eres un experto en turismo de Nicaragua. $exclusion

Devuelve un JSON array de exactamente 20 destinos turísticos de Nicaragua que NO estén en la lista de exclusión.
Incluye variedad: volcanes, ciudades coloniales, playas, lagos, reservas naturales, sitios culturales.

Cada objeto DEBE tener EXACTAMENTE estos campos (sin extras):
  "name": string (nombre oficial del lugar en español),
  "description": string (descripción atractiva en español, 2-3 oraciones),
  "category": string (uno de: naturaleza, cultura, historia, playa, aventura, gastronomia, ciudad),
  "highlight": string (una oración impactante en español, máximo 15 palabras),
  "latitude": number (coordenadas GPS precisas),
  "longitude": number,
  "address": string (dirección legible, ciudad o departamento en Nicaragua)

Responde ÚNICAMENTE con el JSON array. Sin markdown, sin explicación.
''';

    final raw = await _callGemini(prompt);
    return _parseBatch(raw);
  }

  /// Searches for up to 5 Nicaragua tourist destinations matching [query].
  Future<List<GeminiDestinationDto>> searchDestinations(String query) async {
    final prompt =
        '''
Eres un experto en turismo de Nicaragua.
Busca EXACTAMENTE hasta 5 destinos turísticos de Nicaragua relacionados con: "$query".

Cada objeto DEBE tener EXACTAMENTE estos campos (sin extras):
  "name": string (nombre oficial del lugar en español),
  "description": string (descripción atractiva en español, 2-3 oraciones),
  "category": string (uno de: naturaleza, cultura, historia, playa, aventura, gastronomia, ciudad),
  "highlight": string (una oración impactante en español, máximo 15 palabras),
  "latitude": number (coordenadas GPS precisas),
  "longitude": number,
  "address": string (dirección legible, ciudad o departamento en Nicaragua)

Responde ÚNICAMENTE con el JSON array (máximo 5 elementos). Array vacío [] si no hay resultados. Sin markdown, sin explicación.
''';
    final raw = await _callGemini(prompt);
    return _parseBatch(raw);
  }

  // Private

  static const int _maxRetries = 3;
  static const Duration _retryBaseDelay = Duration(seconds: 3);

  Future<String> _callGemini(String prompt) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '$_model:generateContent',
          queryParameters: {'key': ApiClient.geminiApiKey},
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {'temperature': 0.5, 'maxOutputTokens': 4096},
          },
        );

        final data = response.data;
        if (data == null) throw GeminiDataSourceException('Empty response');

        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw GeminiDataSourceException('No candidates');
        }

        final content = candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        final text = parts?.first['text'] as String?;

        if (text == null || text.isEmpty) {
          throw GeminiDataSourceException('Empty text in response');
        }

        return text.trim();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 429 && attempt < _maxRetries) {
          await Future<void>.delayed(_retryBaseDelay * (attempt + 1));
          continue;
        }
        if (status == 429) {
          throw GeminiDataSourceException(
            'Rate limit exceeded after $_maxRetries retries.',
          );
        }
        if (status == 401 || status == 403) {
          throw GeminiDataSourceException('Invalid Gemini API key.');
        }
        throw GeminiDataSourceException(e.message ?? 'Network error.');
      }
    }
    throw GeminiDataSourceException('Request failed after retries.');
  }

  List<GeminiDestinationDto> _parseBatch(String raw) {
    try {
      var cleaned = raw.trim();
      // Strip markdown code fences if present
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'```[a-z]*\n?'), '').trim();
      }
      final decoded = jsonDecode(cleaned);
      if (decoded is! List) return [];

      final result = <GeminiDestinationDto>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final dto = _parseItem(item);
        if (dto != null) result.add(dto);
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  GeminiDestinationDto? _parseItem(Map<String, dynamic> json) {
    try {
      final name = json['name'] as String?;
      if (name == null || name.isEmpty) return null;

      final lat = _toDouble(json['latitude']);
      final lon = _toDouble(json['longitude']);
      if (lat == null || lon == null) return null;

      return GeminiDestinationDto(
        name: name,
        description: (json['description'] as String?) ?? '',
        category: (json['category'] as String?) ?? 'lugar',
        highlight: (json['highlight'] as String?) ?? '',
        latitude: lat,
        longitude: lon,
        address: (json['address'] as String?) ?? 'Nicaragua',
      );
    } catch (_) {
      return null;
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class GeminiDataSourceException implements Exception {
  const GeminiDataSourceException(this.message);
  final String message;

  @override
  String toString() => 'GeminiDataSourceException: $message';
}
