import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sleep_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sleep_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationMinutes INTEGER,
        alarmTime TEXT,
        quality TEXT,
        notes TEXT
      )
    ''');
  }

  // ── INSERT ──────────────────────────────────────────────────────────────────
  Future<int> insertSleepRecord(SleepRecord record) async {
    final db = await database;
    final map = record.toMap()..remove('id');
    return db.insert('sleep_records', map);
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────────
  Future<int> updateSleepRecord(SleepRecord record) async {
    final db = await database;
    return db.update(
      'sleep_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // ── GET ALL ─────────────────────────────────────────────────────────────────
  Future<List<SleepRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('sleep_records', orderBy: 'startTime DESC');
    return maps.map((m) => SleepRecord.fromMap(m)).toList();
  }

  // ── GET RECENT N ────────────────────────────────────────────────────────────
  Future<List<SleepRecord>> getRecentRecords(int limit) async {
    final db = await database;
    final maps = await db.query(
      'sleep_records',
      orderBy: 'startTime DESC',
      limit: limit,
    );
    return maps.map((m) => SleepRecord.fromMap(m)).toList();
  }

  // ── GET ACTIVE SESSION (endTime IS NULL) ────────────────────────────────────
  Future<SleepRecord?> getActiveSession() async {
    final db = await database;
    final maps = await db.query(
      'sleep_records',
      where: 'endTime IS NULL',
      orderBy: 'startTime DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SleepRecord.fromMap(maps.first);
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────
  Future<int> deleteSleepRecord(int id) async {
    final db = await database;
    return db.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
  }

  // ── STATS HELPERS ───────────────────────────────────────────────────────────
  Future<double> averageSleepDuration() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(durationMinutes) as avg FROM sleep_records WHERE durationMinutes IS NOT NULL',
    );
    return (result.first['avg'] as num?)?.toDouble() ?? 0;
  }

  Future<int> totalNightsLogged() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM sleep_records WHERE durationMinutes IS NOT NULL',
    );
    return (result.first['cnt'] as int?) ?? 0;
  }
}
