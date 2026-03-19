import 'package:connectivity_plus/connectivity_plus.dart';

import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/destination_model.dart';

// Offlinefirst repository: always reads from SQLite.
// Seeds from OpenTripMap API only when cache is empty and device is online.
class DestinationRepository {
  DestinationRepository({
    required DatabaseHelper local,
    required DestinationsRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final DatabaseHelper _local;
  final DestinationsRemoteDataSource _remote;

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _fetchAndStore() async {
    final list = await _remote.fetchDestinationsList();
    final details = await Future.wait(
      list.map((d) => _remote.fetchPlaceDetails(d.xid)),
    );
    await _local.insertAll(details);
  }

  // Returns all destinations. Reads from SQLite.
  // If cache is empty and online, fetches from API and stores before returning.
  Future<List<Destination>> getDestinations() async {
    final cached = await _local.getAll();
    if (cached.isNotEmpty) return cached;

    if (!await _isOnline()) return [];

    await _fetchAndStore();
    return _local.getAll();
  }

  // Returns a destination by xid. Reads from SQLite first.
  // If not found and online, fetches from API, stores, and returns.
  Future<Destination?> getDestinationById(String xid) async {
    final cached = await _local.getById(xid);
    if (cached != null) return cached;

    if (!await _isOnline()) return null;

    final destination = await _remote.fetchPlaceDetails(xid);
    await _local.insertAll([destination]);
    return destination;
  }

  // Clears cache and re-seeds from API. Requires online.
  Future<void> refresh() async {
    if (!await _isOnline()) return;

    await _local.deleteAll();
    await _fetchAndStore();
  }
}
