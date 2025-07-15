import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/device_model.dart';

class DeviceDatabase {
  static final DeviceDatabase _instance = DeviceDatabase._internal();
  factory DeviceDatabase() => _instance;
  DeviceDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'device_db.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            deviceId TEXT,
            batteryLevel INTEGER,
            lastSyncTime TEXT,
            isOnline INTEGER
          )
        ''');
      },
      version: 1,
    );
    return _database!;
  }

  Future<void> insertDevice(DeviceModel device) async {
    final db = await database;
    await db.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeviceModel>> getDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('devices');
    return List.generate(maps.length, (i) => DeviceModel.fromMap(maps[i]));
  }

  Future<void> deleteDevice(String deviceId) async {
    final db = await database;
    await db.delete('devices', where: 'deviceId = ?', whereArgs: [deviceId]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('devices');
  }
}
