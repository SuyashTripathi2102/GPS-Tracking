import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChallengeDB {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'challenges.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE challenges (
          id TEXT PRIMARY KEY,
          title TEXT,
          subtitle TEXT,
          reward TEXT,
          status TEXT
        )
      ''');
      },
    );
  }

  static Future<void> saveChallenge(Map<String, dynamic> challenge) async {
    final db = await ChallengeDB.db;
    await db.insert(
      'challenges',
      challenge,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchChallenges() async {
    final db = await ChallengeDB.db;
    return db.query('challenges');
  }
}
