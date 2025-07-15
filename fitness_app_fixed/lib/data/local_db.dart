import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbHelper {
  static final LocalDbHelper instance = LocalDbHelper._internal();
  Database? _db;

  LocalDbHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'fitness.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            steps INTEGER,
            distance_km REAL,
            active_minutes INTEGER
          )
        ''');
      },
    );
  }
}
