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
    );
  }

  Future<void> _onCreate(Database database, int version) async {
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
        rate REAL
      )
    ''');
  }

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

  Future<List<Destination>> getAll() async {
    final database = await db;
    final rows = await database.query(tableDestinations);
    return rows.map((row) => _rowToDestination(row)).toList();
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

  Future<void> deleteAll() async {
    final database = await db;
    await database.delete(tableDestinations);
  }

  Destination _rowToDestination(Map<String, dynamic> row) {
    return Destination.fromMap(_sanitizeRow(row));
  }

  Map<String, dynamic> _sanitizeRow(Map<String, dynamic> row) {
    return row.map((key, value) {
      if (value is num && (key == 'latitude' || key == 'longitude' || key == 'rate')) {
        return MapEntry(key, value.toDouble());
      }
      return MapEntry(key, value);
    });
  }
}
