import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/destination_model.dart';
import '../models/nearby_poi.dart';

/// Offline-first repository.
///
/// Main flow:
///   1. Read from SQLite (paginated).
///   2. When SQLite is exhausted AND user scrolls more → fetch next Gemini batch.
///   3. Gemini returns 10 fully-detailed destinations → stored in SQLite → served.
///   4. Deduplication: pass existing names to Gemini so it never repeats.
///
/// OTM is only used for the "Explorar Alrededores" feature (1 radius call).
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

  // Gemini batch fetch

  /// Fetches 10 new destinations from Gemini (excluding what we already have)
  /// and persists them in SQLite.
  Future<void> _fetchGeminiBatch() async {
    final existingNames = await _local.getAllNames();
    final batch = await _gemini.fetchBatch(existingNames);
    if (batch.isEmpty) return;

    final destinations = batch.map((dto) {
      // xid = sanitized name slug (stable, reproducible)
      final xid = 'gem_${dto.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      return Destination(
        xid: xid,
        name: dto.name,
        description: dto.description.isNotEmpty ? dto.description : null,
        imageUrl: dto.imageUrl.isNotEmpty ? dto.imageUrl : null,
        category: dto.category,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address.isNotEmpty ? dto.address : null,
        highlight: dto.highlight.isNotEmpty ? dto.highlight : null,
        aiTips: null,
      );
    }).toList();

    await _local.insertAll(destinations);
  }

  // Pagination

  /// Returns a page of destinations.
  ///
  /// If the requested page starts beyond current SQLite count, triggers a
  /// Gemini batch fetch first so the next page is always available.
  Future<List<Destination>> getDestinationsPage(int page) async {
    final offset = page * pageSize;
    final count = await _local.getCount();

    // Need to fetch more: SQLite doesn't have enough yet
    if (offset >= count) {
      if (!await _isOnline()) return [];
      await _fetchGeminiBatch();
    }

    return _local.getPage(pageSize, offset);
  }

  /// Whether more pages may be available (either in SQLite or via Gemini).
  /// Returns true if the last page was full (could be more) OR there's internet.
  Future<bool> hasMore(int currentCount) async {
    // If last batch was full, there might be more
    if (currentCount % pageSize == 0 && currentCount > 0) return true;
    // Could still fetch from Gemini if online
    return _isOnline();
  }

  Future<int> getTotalCount() => _local.getCount();

  // Detail

  Future<Destination?> getDestinationById(String xid) async {
    return _local.getById(xid);
  }

  // AI Tips

  Future<String?> getAiTips(String xid, String name, String category) async {
    final cached = await _local.getById(xid);
    if (cached?.aiTips != null && cached!.aiTips!.isNotEmpty) {
      return cached.aiTips;
    }
    if (!await _isOnline()) return null;

    final tips = await _gemini.fetchAiTips(name, category);
    await _local.updateAiTips(xid, tips);
    return tips;
  }

  // Nearby POIs (OTM)

  Future<List<NearbyPoi>> getNearbyPois(double lat, double lon) async {
    if (!await _isOnline()) return [];
    return _remote.fetchNearbyPois(lat: lat, lon: lon);
  }

  // Search

  Future<List<Destination>> searchDestinations(String query) async {
    // Local first
    final localResults = await _local.search(query);
    if (localResults.isNotEmpty) return localResults;

    if (!await _isOnline()) return [];

    final batch = await _gemini.searchDestinations(query);
    if (batch.isEmpty) return [];

    final destinations = batch.map((dto) {
      final xid = 'search_${dto.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      return Destination(
        xid: xid,
        name: dto.name,
        description: dto.description.isNotEmpty ? dto.description : null,
        imageUrl: dto.imageUrl.isNotEmpty ? dto.imageUrl : null,
        category: dto.category,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address.isNotEmpty ? dto.address : null,
        highlight: dto.highlight.isNotEmpty ? dto.highlight : null,
        aiTips: null,
      );
    }).toList();

    await _local.insertAll(destinations);
    return destinations;
  }

  // Refresh

  Future<void> refresh() async {
    if (!await _isOnline()) return;
    await _local.deleteAll();
    await _fetchGeminiBatch();
  }
}
