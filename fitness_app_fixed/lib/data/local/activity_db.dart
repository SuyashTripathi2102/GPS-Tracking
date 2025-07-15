import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ActivityDB {
  static final ActivityDB instance = ActivityDB._init();
  static Database? _database;

  ActivityDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('activity.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        steps INTEGER,
        distance REAL,
        activeMinutes INTEGER
      )
    ''');
  }

  Future<void> insertActivity(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert(
      'activity',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllActivities() async {
    final db = await instance.database;
    return await db.query('activity', orderBy: 'date DESC');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
