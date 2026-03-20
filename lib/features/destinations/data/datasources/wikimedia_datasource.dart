import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/config/api_client.dart';

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
  // Using 1.5s to be gentler with the API and avoid rate limiting.
  static const Duration _nominatimDelay = Duration(milliseconds: 1500);

  /// Fetches a real image URL for [name] near [lat],[lon].
  ///
  /// Respects Nominatim rate-limit by delaying before each call.
  Future<String?> fetchImageUrl(
    String name,
    double lat,
    double lon,
  ) async {
    debugPrint('[Wikimedia] fetchImageUrl: "$name"');
    await Future<void>.delayed(_nominatimDelay);
    final qid = await _fetchWikidataQid(name, lat, lon);
    debugPrint('[Wikimedia] "$name" → qid=$qid');
    if (qid == null) return null;

    final fileName = await _fetchWikidataImageName(qid);
    debugPrint('[Wikimedia] "$name" qid=$qid → fileName=$fileName');
    if (fileName == null || fileName.isEmpty) return null;

    final url = _buildCommonsUrl(fileName);
    debugPrint('[Wikimedia] "$name" → final url=$url');
    return url;
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
    } catch (e) {
      debugPrint('[Wikimedia] Nominatim FAILED for "$name": $e');
      return null;
    }
  }

  // Step 2: Wikidata API → image file name from P18 (via wbgetentities)

  String? _p18FilenameFromClaims(Map<String, dynamic>? claims) {
    final p18 = claims?['P18'] as List<dynamic>?;
    if (p18 == null || p18.isEmpty) return null;
    for (final claim in p18) {
      if (claim is! Map<String, dynamic>) continue;
      final mainsnak = claim['mainsnak'] as Map<String, dynamic>?;
      if (mainsnak == null) continue;
      final datavalue = mainsnak['datavalue'] as Map<String, dynamic>?;
      final value = datavalue?['value'];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  Future<String?> _fetchWikidataImageName(String qid) async {
    try {
      final response = await _wikidata.get<dynamic>(
        'api.php',
        queryParameters: {
          'action': 'wbgetentities',
          'ids': qid,
          'props': 'claims',
          'format': 'json',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      final entities = data?['entities'] as Map<String, dynamic>?;
      final entity = entities?[qid] as Map<String, dynamic>?;
      if (entity == null || entity.containsKey('missing')) return null;

      final claims = entity['claims'] as Map<String, dynamic>?;
      return _p18FilenameFromClaims(claims);
    } catch (e) {
      debugPrint('[Wikimedia] Wikidata P18 FAILED for qid=$qid: $e');
      return null;
    }
  }

  // Step 3: Build Wikimedia Commons direct image URL

  String _buildCommonsUrl(String fileName) {
    final formatted = fileName.replaceAll(' ', '_');
    return 'https://commons.wikimedia.org/wiki/Special:FilePath/$formatted?width=640';
  }
}
