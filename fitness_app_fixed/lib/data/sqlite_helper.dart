import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fitness_app_fixed/models/activity.dart';

class SQLiteHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steps INTEGER,
        distance REAL,
        duration INTEGER,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        gender TEXT,
        theme TEXT,
        avatarUrl TEXT
      )
    ''');
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Activity>> getWeeklyActivity() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT strftime('%w', date) as day, SUM(steps) as steps
      FROM activity
      WHERE date >= date('now', '-6 days')
      GROUP BY day
      ORDER BY day
    ''');
    return result
        .map(
          (e) => Activity.fromMap({
            'day': _dayFromInt(int.parse(e['day'] as String)),
            'steps': e['steps'] ?? 0,
          }),
        )
        .toList();
  }

  String _dayFromInt(int d) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[d];
  }
}
