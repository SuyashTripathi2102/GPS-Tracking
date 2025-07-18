import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProfileDBHelper {
  static final ProfileDBHelper _instance = ProfileDBHelper._internal();
  factory ProfileDBHelper() => _instance;
  ProfileDBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'profile.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE profile(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          weeklySteps INTEGER,
          achievements TEXT,
          theme TEXT,
          gender TEXT,
          avatarPath TEXT
        )
      ''');
      },
    );
  }

  Future<void> insertOrUpdateProfile({
    required String name,
    required String email,
    required int weeklySteps,
    required List<String> achievements,
    required String theme,
    required String gender,
    String? avatarPath,
  }) async {
    final db = await database;
    final data = {
      'name': name,
      'email': email,
      'weeklySteps': weeklySteps,
      'achievements': achievements.join(','),
      'theme': theme,
      'gender': gender,
      'avatarPath': avatarPath ?? '',
    };
    final existing = await db.query('profile', limit: 1);
    if (existing.isEmpty) {
      await db.insert('profile', data);
    } else {
      await db.update(
        'profile',
        data,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateGender(String uid, String gender) async {
    final db = await database;
    final existing = await db.query('profile', limit: 1);
    if (existing.isNotEmpty) {
      await db.update(
        'profile',
        {'gender': gender},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }
}
