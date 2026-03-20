import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/destination_model.dart';
import '../models/nearby_poi.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  factory DatabaseHelper() => instance;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    return _db = await init();
  }

  Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    await _createDestinationsTable(database);
    await _createNearbyPoisTable(database);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // aiTips column removed — rebuild destinations table without it.
      // SQLite doesn't support DROP COLUMN before 3.35; recreate instead.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${tableDestinations}_new (
          xid        TEXT    PRIMARY KEY,
          name       TEXT    NOT NULL,
          description TEXT,
          imageUrl   TEXT,
          category   TEXT    NOT NULL,
          latitude   REAL    NOT NULL,
          longitude  REAL    NOT NULL,
          address    TEXT,
          highlight  TEXT,
          createdAt  INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        INSERT INTO ${tableDestinations}_new
          (xid, name, description, imageUrl, category, latitude, longitude, address, highlight, createdAt)
        SELECT xid, name, description, imageUrl, category, latitude, longitude, address, highlight, createdAt
        FROM $tableDestinations
      ''');
      await db.execute('DROP TABLE $tableDestinations');
      await db.execute('ALTER TABLE ${tableDestinations}_new RENAME TO $tableDestinations');
    }
  }

  Future<void> _createDestinationsTable(Database database) async {
    await database.execute('''
      CREATE TABLE $tableDestinations (
        xid        TEXT    PRIMARY KEY,
        name       TEXT    NOT NULL,
        description TEXT,
        imageUrl   TEXT,
        category   TEXT    NOT NULL,
        latitude   REAL    NOT NULL,
        longitude  REAL    NOT NULL,
        address    TEXT,
        highlight  TEXT,
        createdAt  INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createNearbyPoisTable(Database database) async {
    await database.execute('''
      CREATE TABLE $tableNearbyPois (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        destinationXid  TEXT    NOT NULL,
        name            TEXT    NOT NULL,
        kinds           TEXT,
        latitude        REAL    NOT NULL,
        longitude       REAL    NOT NULL,
        distanceMeters  REAL,
        FOREIGN KEY (destinationXid) REFERENCES $tableDestinations(xid) ON DELETE CASCADE
      )
    ''');
  }

  // ── Destinations ────────────────────────────────────────────────────────────

  Future<void> insertAll(List<Destination> destinations) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = database.batch();
    for (final d in destinations) {
      final map = d.toMap();
      map['createdAt'] = now; // always stamp fresh fetches
      batch.insert(
        tableDestinations,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }


  Future<void> updateImageUrl(String xid, String url) async {
    final database = await db;
    await database.update(
      tableDestinations,
      {'imageUrl': url},
      where: 'xid = ?',
      whereArgs: [xid],
    );
  }

  Future<List<Destination>> getPage(int limit, int offset) async {
    final database = await db;
    final rows = await database.query(
      tableDestinations,
      orderBy: 'createdAt DESC',   // newest batch first
      limit: limit,
      offset: offset,
    );
    return rows.map(Destination.fromMap).toList();
  }

  Future<int> getCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableDestinations',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<List<String>> getAllNames() async {
    final database = await db;
    final rows = await database.query(tableDestinations, columns: ['name']);
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<Destination?> getById(String xid) async {
    final database = await db;
    final rows = await database.query(
      tableDestinations,
      where: 'xid = ?',
      whereArgs: [xid],
    );
    if (rows.isEmpty) return null;
    return Destination.fromMap(rows.first);
  }

  Future<List<Destination>> search(String query) async {
    final database = await db;
    final like = '%$query%';
    final rows = await database.query(
      tableDestinations,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: [like, like],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Destination.fromMap).toList();
  }

  // ── Nearby POIs ─────────────────────────────────────────────────────────────

  Future<void> insertNearbyPois(
    String destinationXid,
    List<NearbyPoi> pois,
  ) async {
    final database = await db;
    // Remove stale entries first so a refresh gets clean data
    await database.delete(
      tableNearbyPois,
      where: 'destinationXid = ?',
      whereArgs: [destinationXid],
    );
    final batch = database.batch();
    for (final poi in pois) {
      batch.insert(tableNearbyPois, poi.toMap(destinationXid));
    }
    await batch.commit(noResult: true);
  }

  Future<List<NearbyPoi>> getNearbyPois(String destinationXid) async {
    final database = await db;
    final rows = await database.query(
      tableNearbyPois,
      where: 'destinationXid = ?',
      whereArgs: [destinationXid],
      orderBy: 'distanceMeters ASC',
    );
    return rows.map(NearbyPoi.fromMap).toList();
  }

  Future<bool> hasNearbyPois(String destinationXid) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableNearbyPois WHERE destinationXid = ?',
      [destinationXid],
    );
    return ((result.first['count'] as int?) ?? 0) > 0;
  }
}
