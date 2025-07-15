import 'package:fitness_app_fixed/models/activity_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  SQLiteService._privateConstructor();
  static final SQLiteService instance = SQLiteService._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness.db');

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
  }

  Future<List<ActivityModel>> getAllActivities() async {
    final db = await database;
    final result = await db.query('activity', orderBy: 'date DESC');
    return result.map((e) => ActivityModel.fromMap(e)).toList();
  }

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await database;
    await db.insert('activity', activity.toMap());
  }
}
