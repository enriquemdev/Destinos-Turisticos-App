import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../domain/dtos/destinations/destination_dto.dart';
import '../../../domain/dtos/destinations/nearby_poi_dto.dart';
import 'db_constants.dart';

class DestinationsLocalDataSource {
  DestinationsLocalDataSource._();
  static final DestinationsLocalDataSource instance =
      DestinationsLocalDataSource._();
  factory DestinationsLocalDataSource() => instance;

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
      await db.execute(
          'ALTER TABLE ${tableDestinations}_new RENAME TO $tableDestinations');
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

  // ── Mappers ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> _dtoToMap(DestinationDto dto) => {
        'xid': dto.xid,
        'name': dto.name,
        'description': dto.description,
        'imageUrl': dto.imageUrl,
        'category': dto.category,
        'latitude': dto.latitude,
        'longitude': dto.longitude,
        'address': dto.address,
        'highlight': dto.highlight,
        'createdAt':
            dto.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      };

  DestinationDto _mapToDto(Map<String, dynamic> map) => DestinationDto(
        xid: map['xid'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        imageUrl: map['imageUrl'] as String?,
        category: map['category'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        address: map['address'] as String?,
        highlight: map['highlight'] as String?,
        createdAt: map['createdAt'] as int?,
      );

  Map<String, dynamic> _poiDtoToMap(
          NearbyPoiDto dto, String destinationXid) =>
      {
        'destinationXid': destinationXid,
        'name': dto.name,
        'kinds': dto.kinds,
        'latitude': dto.latitude,
        'longitude': dto.longitude,
        'distanceMeters': dto.distanceMeters,
      };

  NearbyPoiDto _mapToPoiDto(Map<String, dynamic> map) => NearbyPoiDto(
        name: map['name'] as String,
        kinds: (map['kinds'] as String?) ?? '',
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      );

  // ── Destinations ─────────────────────────────────────────────────────────────

  Future<void> insertAll(List<DestinationDto> destinations) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = database.batch();
    for (final d in destinations) {
      final map = _dtoToMap(d);
      map['createdAt'] = now;
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

  Future<List<DestinationDto>> getPage(int limit, int offset) async {
    final database = await db;
    final rows = await database.query(
      tableDestinations,
      orderBy: 'createdAt ASC, xid ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_mapToDto).toList();
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

  Future<DestinationDto?> getById(String xid) async {
    final database = await db;
    final rows = await database.query(
      tableDestinations,
      where: 'xid = ?',
      whereArgs: [xid],
    );
    if (rows.isEmpty) return null;
    return _mapToDto(rows.first);
  }

  Future<List<DestinationDto>> search(String query) async {
    final database = await db;
    final like = '%$query%';
    final rows = await database.query(
      tableDestinations,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: [like, like],
      orderBy: 'createdAt DESC',
    );
    return rows.map(_mapToDto).toList();
  }

  // ── Nearby POIs ──────────────────────────────────────────────────────────────

  Future<void> insertNearbyPois(
    String destinationXid,
    List<NearbyPoiDto> pois,
  ) async {
    final database = await db;
    await database.delete(
      tableNearbyPois,
      where: 'destinationXid = ?',
      whereArgs: [destinationXid],
    );
    final batch = database.batch();
    for (final poi in pois) {
      batch.insert(tableNearbyPois, _poiDtoToMap(poi, destinationXid));
    }
    await batch.commit(noResult: true);
  }

  Future<List<NearbyPoiDto>> getNearbyPois(String destinationXid) async {
    final database = await db;
    final rows = await database.query(
      tableNearbyPois,
      where: 'destinationXid = ?',
      whereArgs: [destinationXid],
      orderBy: 'distanceMeters ASC',
    );
    return rows.map(_mapToPoiDto).toList();
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
