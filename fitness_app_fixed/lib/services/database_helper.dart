import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../screens/activity/activity_history_screen.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness.db');
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

  Future<List<ActivityData>> getAllActivityData() async {
    final db = await instance.database;
    final result = await db.query('activity', orderBy: 'date DESC');
    return result
        .map(
          (e) => ActivityData(
            date: DateTime.parse(e['date'] as String),
            steps: e['steps'] as int,
            distance: (e['distance'] as num).toDouble(),
            activeMinutes: e['activeMinutes'] as int,
          ),
        )
        .toList();
  }
}
