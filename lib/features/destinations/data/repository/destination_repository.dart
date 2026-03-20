import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/destination_model.dart';
import '../models/nearby_poi.dart';

/// Offline-first repository.
///
/// Destinations flow:
///   1. Read SQLite (paginated, newest first).
///   2. When SQLite exhausted AND online → fetch Gemini batch → save → serve.
///   3. Gemini receives exclusion list of existing names → no duplicates.
///
/// Nearby POIs flow:
///   1. Read SQLite cache for destinationXid.
///   2. If empty AND online → fetch OTM radius → save → serve.
///   3. Fully offline if previously fetched.
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

  Future<void> _fetchGeminiBatch() async {
    final existingNames = await _local.getAllNames();
    final batch = await _gemini.fetchBatch(existingNames);
    if (batch.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final destinations = batch.map((dto) {
      final xid =
          'gem_${dto.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
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
        createdAt: now,
      );
    }).toList();

    await _local.insertAll(destinations);
  }

  // Pagination

  /// Returns a page of destinations (newest first).
  ///
  /// Triggers a Gemini batch fetch if SQLite doesn't have enough for [page].
  Future<List<Destination>> getDestinationsPage(int page) async {
    final offset = page * pageSize;
    final count = await _local.getCount();

    if (offset >= count) {
      if (!await _isOnline()) return [];
      await _fetchGeminiBatch();
    }

    return _local.getPage(pageSize, offset);
  }

  Future<int> getTotalCount() => _local.getCount();

  // Detail

  Future<Destination?> getDestinationById(String xid) async {
    return _local.getById(xid);
  }

  // AI Tips

  Future<String?> getAiTips(
    String xid,
    String name,
    String category,
  ) async {
    final cached = await _local.getById(xid);
    if (cached?.aiTips != null && cached!.aiTips!.isNotEmpty) {
      return cached.aiTips;
    }
    if (!await _isOnline()) return null;

    final tips = await _gemini.fetchAiTips(name, category);
    await _local.updateAiTips(xid, tips);
    return tips;
  }

  // Nearby POIs — offline-first

  /// Returns nearby POIs for [destinationXid].
  ///
  /// Reads SQLite cache first. If empty and online, fetches from OTM and
  /// persists before returning so subsequent calls are offline-capable.
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

  Future<List<Destination>> searchDestinations(String query) async {
    final localResults = await _local.search(query);
    if (localResults.isNotEmpty) return localResults;

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
        imageUrl: dto.imageUrl.isNotEmpty ? dto.imageUrl : null,
        category: dto.category,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address.isNotEmpty ? dto.address : null,
        highlight: dto.highlight.isNotEmpty ? dto.highlight : null,
        aiTips: null,
        createdAt: now,
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
