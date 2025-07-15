import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _db;

  DBHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('fitness_app.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        name TEXT,
        gender TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('user_profile', data);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final result = await db.query('user_profile', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'user_profile',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('user_profile');
  }
}
