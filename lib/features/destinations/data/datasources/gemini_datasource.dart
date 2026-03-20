import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';

/// Lightweight DTO returned by Gemini for destination discovery.
class GeminiDestinationDto {
  const GeminiDestinationDto({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.highlight,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final String highlight;

  @override
  String toString() => 'GeminiDestinationDto($name)';
}

/// All interactions with Gemini Flash 2.5.
///
/// Responsibilities:
///   1. Provide a curated list of top Nicaragua tourist destinations.
///   2. Generate travel tips for a specific destination (cached after first call).
///   3. Search destinations by natural language query.
///
/// Token usage is kept minimal by requesting small, structured responses.
class GeminiDataSource {
  GeminiDataSource({Dio? dio}) : _dio = dio ?? ApiClient.createGemini();

  final Dio _dio;

  static const String _model = 'models/gemini-2.5-flash-lite';

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns ~25 curated top tourist destinations in Nicaragua.
  /// Each entry includes coordinates for OpenTripMap enrichment.
  Future<List<GeminiDestinationDto>> fetchTopDestinations() async {
    const prompt = '''
Return a JSON array of the top 15 tourist destinations in Nicaragua.
Each object must have EXACTLY these fields (no extras):
  "name": string (in Spanish, official place name),
  "latitude": number,
  "longitude": number,
  "category": string (one of: naturaleza, cultura, historia, playa, aventura, gastronomia, ciudad),
  "highlight": string (one compelling sentence in Spanish, max 20 words).

Include a mix of: volcanoes, colonial cities, beaches, lakes, nature reserves, and cultural sites.
Respond ONLY with the raw JSON array. No markdown, no explanation.
''';

    final raw = await _callGemini(prompt);
    return _parseDestinationList(raw);
  }

  /// Generates concise travel tips for a specific destination.
  /// Result should be cached in SQLite to avoid redundant calls.
  Future<String> fetchAiTips(String destinationName, String category) async {
    final prompt = '''
Write 3 short travel tips in Spanish for visiting "$destinationName" ($category) in Nicaragua.
Format as a numbered list. Each tip max 2 sentences. Be practical and specific.
Respond ONLY with the numbered list. No introduction, no markdown.
''';

    return _callGemini(prompt);
  }

  /// Searches for Nicaragua tourist destinations matching [query].
  /// Returns a list of destination DTOs (may be empty if nothing found).
  Future<List<GeminiDestinationDto>> searchDestinations(String query) async {
    final prompt = '''
Return a JSON array of up to 10 Nicaragua tourist destinations matching this search: "$query".
Each object must have EXACTLY these fields:
  "name": string (in Spanish, official place name),
  "latitude": number,
  "longitude": number,
  "category": string (one of: naturaleza, cultura, historia, playa, aventura, gastronomia, ciudad),
  "highlight": string (one compelling sentence in Spanish, max 20 words).

Respond ONLY with the raw JSON array. No markdown, no explanation. Empty array [] if nothing found.
''';

    final raw = await _callGemini(prompt);
    return _parseDestinationList(raw);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

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
            'generationConfig': {
              'temperature': 0.4,
              'maxOutputTokens': 2048,
            },
          },
        );

        final data = response.data;
        if (data == null) {
          throw GeminiDataSourceException('Empty Gemini response');
        }

        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw GeminiDataSourceException('No candidates in Gemini response');
        }

        final content =
            candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        final text = parts?.first['text'] as String?;

        if (text == null || text.isEmpty) {
          throw GeminiDataSourceException('Empty text in Gemini response');
        }

        return text.trim();
      } on DioException catch (e) {
        final status = e.response?.statusCode;

        // Retry on 429 (rate limit) with exponential backoff
        if (status == 429 && attempt < _maxRetries) {
          await Future<void>.delayed(_retryBaseDelay * (attempt + 1));
          continue;
        }

        if (status == 429) {
          throw GeminiDataSourceException(
            'Gemini rate limit exceeded after $_maxRetries retries. Try again later.',
          );
        }
        if (status == 401 || status == 403) {
          throw GeminiDataSourceException('Invalid Gemini API key.');
        }
        throw GeminiDataSourceException(e.message ?? 'Gemini network error.');
      }
    }
    // Should not reach here, but just in case
    throw GeminiDataSourceException('Gemini request failed after retries.');
  }

  List<GeminiDestinationDto> _parseDestinationList(String raw) {
    try {
      // Strip potential markdown code fences
      var cleaned = raw.trim();
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
      final highlight = json['highlight'] as String?;
      final category = json['category'] as String?;
      final lat = _toDouble(json['latitude']);
      final lon = _toDouble(json['longitude']);

      if (name == null || name.isEmpty) return null;
      if (lat == null || lon == null) return null;

      return GeminiDestinationDto(
        name: name,
        latitude: lat,
        longitude: lon,
        category: category ?? 'lugar',
        highlight: highlight ?? '',
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
