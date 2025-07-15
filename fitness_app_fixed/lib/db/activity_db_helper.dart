import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity_model.dart';

class ActivityDBHelper {
  static final ActivityDBHelper _instance = ActivityDBHelper._internal();
  factory ActivityDBHelper() => _instance;
  ActivityDBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'activity_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE activities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            steps INTEGER,
            distance REAL,
            activeTime INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await database;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityModel>> fetchAll() async {
    final db = await database;
    final maps = await db.query('activities');
    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }
}
