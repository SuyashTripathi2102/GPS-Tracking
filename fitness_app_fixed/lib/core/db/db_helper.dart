import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activityType TEXT,
            distance REAL,
            calories REAL,
            duration INTEGER,
            timestamp TEXT,
            heartRate INTEGER,
            co2 REAL,
            status TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE sessions ADD COLUMN heartRate INTEGER;',
          );
          await db.execute('ALTER TABLE sessions ADD COLUMN co2 REAL;');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE sessions ADD COLUMN status TEXT;');
        }
      },
    );
  }

  static Future<void> insertSession(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sessions', data);
  }

  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    final db = await database;
    return await db.query('sessions', orderBy: 'timestamp DESC');
  }

  static Future<void> migrateOldSessions() async {
    final db = await database;
    // Check if old table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='activity_sessions'",
    );
    if (tables.isNotEmpty) {
      final oldSessions = await db.query('activity_sessions');
      for (final s in oldSessions) {
        // Only migrate if not already present (by timestamp)
        final exists = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM sessions WHERE timestamp = ?',
            [s['end_time'] ?? s['start_time']],
          ),
        );
        if (exists == 0) {
          await db.insert('sessions', {
            'distance': s['distance'] ?? 0.0,
            'timestamp': s['end_time'] ?? s['start_time'],
            'status': s['status'] ?? 'Completed',
          });
        }
      }
    }
  }
}
