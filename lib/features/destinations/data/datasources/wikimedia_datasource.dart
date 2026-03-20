import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';

/// Resolves a real image URL for a tourist destination using:
///   1. Nominatim (OSM) → extracts Wikidata QID from extratags
///   2. Wikidata API → extracts P18 (image) property
///   3. Wikimedia Commons FilePath → direct image URL
///
/// Returns null on any failure — the caller should fall back to a placeholder.
class WikimediaDataSource {
  WikimediaDataSource({Dio? nominatimDio, Dio? wikidataDio})
      : _nominatim = nominatimDio ?? ApiClient.createNominatim(),
        _wikidata = wikidataDio ?? ApiClient.createWikidata();

  final Dio _nominatim;
  final Dio _wikidata;

  // Nominatim requires at least 1 second between requests (usage policy).
  static const Duration _nominatimDelay = Duration(seconds: 1);

  /// Fetches a real image URL for [name] near [lat],[lon].
  ///
  /// Respects Nominatim rate-limit by delaying before each call.
  Future<String?> fetchImageUrl(
    String name,
    double lat,
    double lon,
  ) async {
    await Future<void>.delayed(_nominatimDelay);
    final qid = await _fetchWikidataQid(name, lat, lon);
    if (qid == null) return null;

    final fileName = await _fetchWikidataImageName(qid);
    if (fileName == null || fileName.isEmpty) return null;

    return _buildCommonsUrl(fileName);
  }

  // Step 1: Nominatim search → Wikidata QID

  Future<String?> _fetchWikidataQid(
    String name,
    double lat,
    double lon,
  ) async {
    try {
      final response = await _nominatim.get<dynamic>(
        'search',
        queryParameters: {
          'q': '$name Nicaragua',
          'format': 'json',
          'extratags': 1,
          'limit': 5,
          'viewbox': '${lon - 0.5},${lat + 0.5},${lon + 0.5},${lat - 0.5}',
          'bounded': 0,
        },
      );

      final results = response.data;
      if (results is! List || results.isEmpty) return null;

      for (final item in results) {
        final extratags = item['extratags'] as Map<String, dynamic>?;
        final qid = extratags?['wikidata'] as String?;
        if (qid != null && qid.startsWith('Q')) return qid;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Step 2: Wikidata API → image file name from P18 property

  Future<String?> _fetchWikidataImageName(String qid) async {
    try {
      final response = await _wikidata.get<dynamic>(
        'api.php',
        queryParameters: {
          'action': 'wbgetclaims',
          'property': 'P18',
          'entity': qid,
          'format': 'json',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      final claims = data?['claims'] as Map<String, dynamic>?;
      final p18 = claims?['P18'] as List<dynamic>?;
      if (p18 == null || p18.isEmpty) return null;

      final mainsnak = p18.first['mainsnak'] as Map<String, dynamic>?;
      final datavalue = mainsnak?['datavalue'] as Map<String, dynamic>?;
      return datavalue?['value'] as String?;
    } catch (_) {
      return null;
    }
  }

  // Step 3: Build Wikimedia Commons direct image URL

  String _buildCommonsUrl(String fileName) {
    final formatted = fileName.replaceAll(' ', '_');
    return 'https://commons.wikimedia.org/wiki/Special:FilePath/$formatted?width=640';
  }
}
