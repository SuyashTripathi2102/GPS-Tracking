import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String path = join(docDir.path, 'fitness.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activity_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steps INTEGER,
        distance REAL,
        activeTime INTEGER,
        co2 REAL,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE gps_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        distance REAL,
        duration INTEGER,
        co2 REAL,
        calories REAL,
        route TEXT,
        date TEXT
      )
    ''');
  }

  Future<int> insertDummyActivity() async {
    Database db = await instance.database;
    return await db.insert('activity_data', {
      'steps': 4500,
      'distance': 3.2,
      'activeTime': 28,
      'co2': 120.5,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    Database db = await instance.database;
    return await db.query('activity_data', orderBy: 'date DESC');
  }

  Future<int> insertGpsSession({
    required double distance,
    required int duration,
    required String route,
    required double co2,
    required double calories,
  }) async {
    Database db = await instance.database;
    return await db.insert('gps_sessions', {
      'distance': distance,
      'duration': duration,
      'co2': co2,
      'calories': calories,
      'route': route,
      'date': DateTime.now().toIso8601String(),
    });
  }
}
