import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/constants/app_constants.dart';
import '../../domain/destination_page_result.dart';
import '../../domain/repositories/i_destination_repository.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../datasources/wikimedia_datasource.dart';
import '../models/destination_model.dart';
import '../models/nearby_poi.dart';

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

class DestinationRepository implements IDestinationRepository {
  DestinationRepository({
    required DatabaseHelper local,
    required DestinationsRemoteDataSource remote,
    required GeminiDataSource gemini,
    required WikimediaDataSource wikimedia,
    this.onImageEnriched,
  })  : _local = local,
        _remote = remote,
        _gemini = gemini,
        _wikimedia = wikimedia;

  /// Called each time a background image enrichment completes for a destination.
  void Function(String xid, String imageUrl)? onImageEnriched;

  final DatabaseHelper _local;
  final DestinationsRemoteDataSource _remote;
  final GeminiDataSource _gemini;
  final WikimediaDataSource _wikimedia;

  // Connectivity

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  // Gemini batch fetch

  /// Fetches one Gemini batch and persists it. Returns whether the DB row count
  /// increased (new xids). Replaces-only batches do not move pagination offset.
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
    final destinations = batch.map((dto) {
      final xid =
          'gem_${dto.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      return Destination(
        xid: xid,
        name: dto.name,
        description: dto.description.isNotEmpty ? dto.description : null,
        imageUrl: null, // enriched in the next step
        category: dto.category,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address.isNotEmpty ? dto.address : null,
        highlight: dto.highlight.isNotEmpty ? dto.highlight : null,
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

  /// Fetches real image URLs via Wikidata for each destination that lacks one.
  /// Runs sequentially (1.5s delay per Nominatim policy). Fire-and-forget.
  ///
  /// Each destination is attempted exactly once — no retries on failure.
  /// On failure, stores [_noImageSentinel] so the destination is skipped
  /// on future enrichment passes.
  Future<void> _enrichImagesSequentially(
    List<Destination> destinations,
  ) async {
    debugPrint('[Repo] enrichImages: start for ${destinations.length} destinations');
    for (final dest in destinations) {
      final existing = await _local.getById(dest.xid);
      final currentUrl = existing?.imageUrl;
      if (currentUrl != null && currentUrl.isNotEmpty) {
        debugPrint('[Repo] enrichImages: ${dest.name} → already has image, skipping');
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
          onImageEnriched?.call(dest.xid, url);
        } else {
          await _local.updateImageUrl(dest.xid, _noImageSentinel);
        }
      } catch (e) {
        debugPrint('[Repo] enrichImages: ${dest.name} FAILED: $e');
        await _local.updateImageUrl(dest.xid, _noImageSentinel);
      }
    }
  }

  // Pagination

  /// Returns a page of destinations and whether infinite scroll should continue.
  ///
  /// Triggers a Gemini batch fetch if SQLite doesn't have enough for [page].
  @override
  Future<DestinationsPageLoadResult> getDestinationsPage(int page) async {
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
        return const DestinationsPageLoadResult(items: [], hasMore: false);
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
    return DestinationsPageLoadResult(items: items, hasMore: hasMore);
  }

  @override
  Future<int> getTotalCount() => _local.getCount();

  // Detail

  @override
  Future<Destination?> getDestinationById(String xid) async {
    return _local.getById(xid);
  }

  // Nearby POIs — offline-first

  /// Returns nearby POIs for [destinationXid].
  ///
  /// Reads SQLite cache first. If empty and online, fetches from OTM and
  /// persists before returning so subsequent calls are offline-capable.
  @override
  Future<List<NearbyPoi>> getNearbyPois(
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

  // Search

  /// Calls Gemini to find up to 5 destinations matching [query].
  ///
  /// Results are saved to SQLite and image enrichment fires for each new entry.
  @override
  Future<List<Destination>> searchDestinations(String query) async {
    if (!await _isOnline()) return [];

    final batch = await _gemini.searchDestinations(query);
    if (batch.isEmpty) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    final destinations = batch.map((dto) {
      final xid =
          'search_${dto.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      return Destination(
        xid: xid,
        name: dto.name,
        description: dto.description.isNotEmpty ? dto.description : null,
        imageUrl: null,
        category: dto.category,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address.isNotEmpty ? dto.address : null,
        highlight: dto.highlight.isNotEmpty ? dto.highlight : null,
        createdAt: now,
      );
    }).toList();

    await _local.insertAll(destinations);
    _enrichImagesSequentially(destinations);
    return destinations;
  }
}
