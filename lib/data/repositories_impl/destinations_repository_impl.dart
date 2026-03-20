import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../domain/constants/app_constants.dart';
import '../../domain/dtos/destinations/destination_dto.dart';
import '../../domain/dtos/destinations/destination_page_result_dto.dart';
import '../../domain/dtos/destinations/nearby_poi_dto.dart';
import '../../domain/repositories/destinations_repository.dart';
import '../datasources/local/destinations_local_data_source.dart';
import '../datasources/remote/destinations_remote_data_source.dart';
import '../datasources/remote/gemini_data_source.dart';
import '../datasources/remote/wikimedia_data_source.dart';

/// Offline-first repository.
///
/// Destinations flow:
///   1. Read SQLite (paginated, insertion order via createdAt ASC).
///   2. When SQLite exhausted AND online → fetch Gemini batch → save → serve.
///   3. Gemini receives exclusion list of existing names → no duplicates.
///
/// Nearby POIs flow:
///   1. Read SQLite cache for destinationXid.
///   2. If empty AND online → fetch OTM radius → save → serve.
///   3. Fully offline if previously fetched.

enum _GeminiFillOutcome { progressed, emptyBatch, noNetNewRows }

class DestinationsRepositoryImpl implements DestinationsRepository {
  DestinationsRepositoryImpl({
    required DestinationsLocalDataSource local,
    required DestinationsRemoteDataSource remote,
    required GeminiDataSource gemini,
    required WikimediaDataSource wikimedia,
    void Function(String xid, String imageUrl)? onImageEnriched,
  })  : _local = local,
        _remote = remote,
        _gemini = gemini,
        _wikimedia = wikimedia,
        _onImageEnriched = onImageEnriched;

  @override
  void Function(String xid, String imageUrl)? get onImageEnriched =>
      _onImageEnriched;

  @override
  set onImageEnriched(void Function(String xid, String imageUrl)? callback) {
    _onImageEnriched = callback;
  }

  void Function(String xid, String imageUrl)? _onImageEnriched;

  final DestinationsLocalDataSource _local;
  final DestinationsRemoteDataSource _remote;
  final GeminiDataSource _gemini;
  final WikimediaDataSource _wikimedia;

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<_GeminiFillOutcome> _fetchGeminiBatch() async {
    final countBefore = await _local.getCount();
    final existingNames = await _local.getAllNames();
    debugPrint('[Repo] _fetchGeminiBatch: excludeNames=${existingNames.length}');
    final batch = await _gemini.fetchBatch(existingNames);
    debugPrint('[Repo] _fetchGeminiBatch: gemini returned ${batch.length} items');
    if (batch.isEmpty) {
      debugPrint('[Repo] _fetchGeminiBatch: empty batch from Gemini');
      return _GeminiFillOutcome.emptyBatch;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final destinations = batch.map((model) {
      final xid =
          'gem_${model.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      return DestinationDto(
        xid: xid,
        name: model.name,
        description: model.description.isNotEmpty ? model.description : null,
        imageUrl: null,
        category: model.category,
        latitude: model.latitude,
        longitude: model.longitude,
        address: model.address.isNotEmpty ? model.address : null,
        highlight: model.highlight.isNotEmpty ? model.highlight : null,
        createdAt: now,
      );
    }).toList();

    await _local.insertAll(destinations);
    final countAfter = await _local.getCount();
    final netNew = countAfter - countBefore;
    debugPrint(
      '[Repo] _fetchGeminiBatch: count $countBefore → $countAfter '
      '(dto rows=${destinations.length}, netNew=$netNew)',
    );
    if (netNew <= 0) {
      debugPrint(
        '[Repo] _fetchGeminiBatch: no new rows (duplicate xids / REPLACE only)',
      );
      _enrichImagesSequentially(destinations);
      return _GeminiFillOutcome.noNetNewRows;
    }

    _enrichImagesSequentially(destinations);
    return _GeminiFillOutcome.progressed;
  }

  static const String _noImageSentinel = '__no_image__';

  Future<void> _enrichImagesSequentially(
    List<DestinationDto> destinations,
  ) async {
    debugPrint(
        '[Repo] enrichImages: start for ${destinations.length} destinations');
    for (final dest in destinations) {
      final existing = await _local.getById(dest.xid);
      final currentUrl = existing?.imageUrl;
      if (currentUrl != null && currentUrl.isNotEmpty) {
        debugPrint(
            '[Repo] enrichImages: ${dest.name} → already has image, skipping');
        // Notify the list store in case it loaded this destination before the
        // image was available in its in-memory snapshot.
        if (currentUrl != _noImageSentinel) {
          _onImageEnriched?.call(dest.xid, currentUrl);
        }
        continue;
      }

      try {
        final url = await _wikimedia.fetchImageUrl(
          dest.name,
          dest.latitude,
          dest.longitude,
        );
        debugPrint('[Repo] enrichImages: ${dest.name} → url=$url');
        if (url != null && url.isNotEmpty) {
          await _local.updateImageUrl(dest.xid, url);
          _onImageEnriched?.call(dest.xid, url);
        } else {
          await _local.updateImageUrl(dest.xid, _noImageSentinel);
        }
      } catch (e) {
        debugPrint('[Repo] enrichImages: ${dest.name} FAILED: $e');
        await _local.updateImageUrl(dest.xid, _noImageSentinel);
      }
    }
  }

  @override
  Future<DestinationPageResultDto> getDestinationsPage(int page) async {
    final offset = page * pageSize;
    var count = await _local.getCount();
    var online = await _isOnline();

    debugPrint(
      '[Repo] getDestinationsPage(page=$page) offset=$offset count=$count online=$online',
    );

    if (offset >= count) {
      if (!online) {
        debugPrint(
          '[Repo] getDestinationsPage: offline, no local data → hasMore=false',
        );
        return const DestinationPageResultDto(items: [], hasMore: false);
      }
      const maxFillAttempts = 8;
      var fillAttempt = 0;
      while (offset >= count && online && fillAttempt < maxFillAttempts) {
        fillAttempt++;
        try {
          final outcome = await _fetchGeminiBatch();
          count = await _local.getCount();
          if (outcome == _GeminiFillOutcome.emptyBatch) break;
          if (offset < count) break;
          if (outcome == _GeminiFillOutcome.noNetNewRows) {
            debugPrint(
              '[Repo] getDestinationsPage: fill $fillAttempt/$maxFillAttempts '
              '— still offset $offset >= count $count, asking Gemini again',
            );
          }
        } on GeminiDataSourceException catch (e) {
          debugPrint('[Repo] getDestinationsPage: Gemini error: $e');
          break;
        }
        online = await _isOnline();
      }
    }

    final items = await _local.getPage(pageSize, offset);
    final totalCount = await _local.getCount();
    online = await _isOnline();

    final hasMore = computeDestinationsHasMore(
      items,
      online: online,
      totalCount: totalCount,
    );
    debugPrint(
      '[Repo] getDestinationsPage: page=$page returned ${items.length} items '
      'totalCount=$totalCount hasMore=$hasMore',
    );
    return DestinationPageResultDto(items: items, hasMore: hasMore);
  }

  @override
  Future<int> getTotalCount() => _local.getCount();

  @override
  Future<DestinationDto?> getDestinationById(String xid) async {
    return _local.getById(xid);
  }

  @override
  Future<List<NearbyPoiDto>> getNearbyPois(
    String destinationXid,
    double lat,
    double lon,
  ) async {
    final cached = await _local.getNearbyPois(destinationXid);
    if (cached.isNotEmpty) return cached;

    if (!await _isOnline()) return [];

    final pois = await _remote.fetchNearbyPois(lat: lat, lon: lon);
    if (pois.isNotEmpty) {
      await _local.insertNearbyPois(destinationXid, pois);
    }
    return pois;
  }

  @override
  Future<List<DestinationDto>> searchDestinations(String query) async {
    if (!await _isOnline()) return [];

    final batch = await _gemini.searchDestinations(query);
    if (batch.isEmpty) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    final destinations = batch.map((model) {
      final xid =
          'search_${model.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      return DestinationDto(
        xid: xid,
        name: model.name,
        description: model.description.isNotEmpty ? model.description : null,
        imageUrl: null,
        category: model.category,
        latitude: model.latitude,
        longitude: model.longitude,
        address: model.address.isNotEmpty ? model.address : null,
        highlight: model.highlight.isNotEmpty ? model.highlight : null,
        createdAt: now,
      );
    }).toList();

    await _local.insertAll(destinations);
    _enrichImagesSequentially(destinations);
    return destinations;
  }
}
