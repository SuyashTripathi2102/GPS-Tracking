import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDB() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_tracker.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            start_time TEXT,
            end_time TEXT,
            distance REAL,
            status TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE gps_tracking (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER,
            latitude REAL,
            longitude REAL,
            timestamp TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<int> insertSession({
    required String userId,
    required String startTime,
    String? endTime,
    double distance = 0.0,
    String status = 'active',
  }) async {
    final db = await initDB();
    return await db.insert('activity_sessions', {
      'user_id': userId,
      'start_time': startTime,
      'end_time': endTime,
      'distance': distance,
      'status': status,
    });
  }

  static Future<void> updateSession({
    required int sessionId,
    required String endTime,
    required double distance,
  }) async {
    final db = await initDB();
    await db.update(
      'activity_sessions',
      {'end_time': endTime, 'distance': distance, 'status': 'completed'},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  static Future<void> insertGPS({
    required int sessionId,
    required double lat,
    required double lng,
    required String timestamp,
  }) async {
    final db = await initDB();
    await db.insert('gps_tracking', {
      'session_id': sessionId,
      'latitude': lat,
      'longitude': lng,
      'timestamp': timestamp,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    final db = await initDB();
    return await db.query('activity_sessions', orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> getSessionPoints(
    int sessionId,
  ) async {
    final db = await initDB();
    return await db.query(
      'gps_tracking',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
}
