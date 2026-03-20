import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/destination_model.dart';

/// Offline-first repository orchestrating Gemini AI + OpenTripMap + SQLite.
///
/// Seeding flow:
///   1. Gemini returns curated Nicaragua destination list (names + coordinates).
///   2. For each destination, OpenTripMap enriches with image, description, address.
///   3. Merged result is stored in SQLite.
///
/// Pagination:
///   Data is served page-by-page from SQLite using LIMIT/OFFSET.
class DestinationRepository {
  DestinationRepository({
    required DatabaseHelper local,
    required DestinationsRemoteDataSource remote,
    required GeminiDataSource gemini,
  })  : _local = local,
        _remote = remote,
        _gemini = gemini;

  final DatabaseHelper _local;
  final DestinationsRemoteDataSource _remote;
  final GeminiDataSource _gemini;

  // Connectivity

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  // Seeding

  static const Duration _batchDelay = Duration(milliseconds: 800);
  static const int _batchSize = 3;

  /// Fetches from Gemini + OpenTripMap and stores all destinations in SQLite.
  Future<void> _fetchAndStore() async {
    // Step 1: Gemini curates top Nicaragua destinations
    final geminiList = await _gemini.fetchTopDestinations();
    if (geminiList.isEmpty) return;

    final stored = <Destination>[];

    // Step 2: Enrich each with OpenTripMap in small batches (rate limit friendly)
    for (var i = 0; i < geminiList.length; i += _batchSize) {
      if (i > 0) await Future<void>.delayed(_batchDelay);

      final batch = geminiList.skip(i).take(_batchSize);
      final enriched = await Future.wait(
        batch.map((dto) => _remote.fetchByCoordinates(
              lat: dto.latitude,
              lon: dto.longitude,
              name: dto.name,
              category: dto.category,
              highlight: dto.highlight,
            )),
      );

      // Use Gemini data as fallback when OTM returns nothing
      for (var j = 0; j < batch.length; j++) {
        final otmResult = enriched[j];
        final dto = batch.elementAt(j);

        if (otmResult != null) {
          stored.add(otmResult);
        } else {
          // Fallback: store Gemini-only destination with synthetic xid
          stored.add(Destination(
            xid: 'gem_${dto.name.toLowerCase().replaceAll(' ', '_')}',
            name: dto.name,
            description: null,
            imageUrl: null,
            category: dto.category,
            latitude: dto.latitude,
            longitude: dto.longitude,
            address: null,
            highlight: dto.highlight,
            aiTips: null,
          ));
        }
      }
    }

    await _local.insertAll(stored);
  }

  // Pagination

  /// Returns a page of destinations from SQLite.
  ///
  /// On first call ([page] == 0), seeds from network if local cache is empty.
  Future<List<Destination>> getDestinationsPage(int page) async {
    final count = await _local.getCount();

    if (count == 0) {
      if (!await _isOnline()) return [];
      await _fetchAndStore();
    }

    return _local.getPage(pageSize, page * pageSize);
  }

  /// Total count for pagination control.
  Future<int> getTotalCount() => _local.getCount();

  // ── Detail ────────────────────────────────────────────────────────────────────

  Future<Destination?> getDestinationById(String xid) async {
    final cached = await _local.getById(xid);
    if (cached != null) return cached;

    if (!await _isOnline()) return null;

    final destination = await _remote.fetchPlaceDetails(xid);
    if (destination != null) {
      await _local.insertAll([destination]);
    }
    return destination;
  }

  // ── AI Tips ───────────────────────────────────────────────────────────────────

  /// Returns AI travel tips for [xid].
  /// Checks SQLite cache first; generates via Gemini if not cached.
  Future<String?> getAiTips(String xid, String name, String category) async {
    // Return cached tips first
    final cached = await _local.getById(xid);
    if (cached?.aiTips != null && cached!.aiTips!.isNotEmpty) {
      return cached.aiTips;
    }

    if (!await _isOnline()) return null;

    final tips = await _gemini.fetchAiTips(name, category);
    await _local.updateAiTips(xid, tips);
    return tips;
  }

  // ── Search ────────────────────────────────────────────────────────────────────

  /// Searches destinations locally first, then with Gemini+OTM if online.
  Future<List<Destination>> searchDestinations(String query) async {
    // Local SQLite search
    final localResults = await _local.search(query);
    if (localResults.isNotEmpty) return localResults;

    if (!await _isOnline()) return [];

    // AI-powered search: Gemini → OTM enrichment
    final geminiList = await _gemini.searchDestinations(query);
    if (geminiList.isEmpty) return [];

    final enriched = <Destination>[];
    for (final dto in geminiList) {
      final result = await _remote.fetchByCoordinates(
        lat: dto.latitude,
        lon: dto.longitude,
        name: dto.name,
        category: dto.category,
        highlight: dto.highlight,
      );
      if (result != null) {
        enriched.add(result);
      } else {
        enriched.add(Destination(
          xid: 'search_${dto.name.toLowerCase().replaceAll(' ', '_')}',
          name: dto.name,
          description: null,
          imageUrl: null,
          category: dto.category,
          latitude: dto.latitude,
          longitude: dto.longitude,
          address: null,
          highlight: dto.highlight,
          aiTips: null,
        ));
      }
    }

    // Persist search results to SQLite
    if (enriched.isNotEmpty) await _local.insertAll(enriched);
    return enriched;
  }

  // ── Refresh ───────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    if (!await _isOnline()) return;
    await _local.deleteAll();
    await _fetchAndStore();
  }
}
