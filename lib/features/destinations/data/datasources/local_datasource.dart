import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/destination_model.dart';

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
    await _createTable(database);
  }

  Future<void> _onUpgrade(Database database, int oldVersion, int newVersion) async {
    // Clean migration: drop and recreate
    await database.execute('DROP TABLE IF EXISTS $tableDestinations');
    await _createTable(database);
  }

  Future<void> _createTable(Database database) async {
    await database.execute('''
      CREATE TABLE $tableDestinations (
        xid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        category TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        url TEXT,
        wikipedia TEXT,
        osm TEXT,
        rate REAL,
        highlight TEXT,
        aiTips TEXT
      )
    ''');
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  Future<void> insertAll(List<Destination> destinations) async {
    final database = await db;
    final batch = database.batch();
    for (final d in destinations) {
      batch.insert(
        tableDestinations,
        d.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateAiTips(String xid, String tips) async {
    final database = await db;
    await database.update(
      tableDestinations,
      {'aiTips': tips},
      where: 'xid = ?',
      whereArgs: [xid],
    );
  }

  Future<void> deleteAll() async {
    final database = await db;
    await database.delete(tableDestinations);
  }

  // ── Read ────────────────────────────────────────────────────────────────────

  Future<List<Destination>> getAll() async {
    final database = await db;
    final rows = await database.query(tableDestinations, orderBy: 'name ASC');
    return rows.map(_rowToDestination).toList();
  }

  /// Returns a single page of [pageSize] destinations, ordered by name.
  Future<List<Destination>> getPage(int limit, int offset) async {
    final database = await db;
    final rows = await database.query(
      tableDestinations,
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_rowToDestination).toList();
  }

  /// Total number of stored destinations.
  Future<int> getCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableDestinations',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<Destination?> getById(String xid) async {
    final database = await db;
    final rows = await database.query(
      tableDestinations,
      where: 'xid = ?',
      whereArgs: [xid],
    );
    if (rows.isEmpty) return null;
    return _rowToDestination(rows.first);
  }

  /// Local keyword search using LIKE on name and category.
  Future<List<Destination>> search(String query) async {
    final database = await db;
    final like = '%$query%';
    final rows = await database.query(
      tableDestinations,
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: [like, like],
      orderBy: 'name ASC',
    );
    return rows.map(_rowToDestination).toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Destination _rowToDestination(Map<String, dynamic> row) {
    return Destination.fromMap(_sanitizeRow(row));
  }

  Map<String, dynamic> _sanitizeRow(Map<String, dynamic> row) {
    return row.map((key, value) {
      if (value is num &&
          (key == 'latitude' || key == 'longitude' || key == 'rate')) {
        return MapEntry(key, value.toDouble());
      }
      return MapEntry(key, value);
    });
  }
}
