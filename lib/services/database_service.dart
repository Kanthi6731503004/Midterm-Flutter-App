import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin_record.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('checkin.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE checkins (
        id TEXT PRIMARY KEY,
        checkin_time TEXT NOT NULL,
        checkin_lat REAL NOT NULL,
        checkin_lng REAL NOT NULL,
        qr_code_value TEXT NOT NULL,
        previous_topic TEXT NOT NULL,
        expected_topic TEXT NOT NULL,
        mood_before INTEGER NOT NULL,
        finish_time TEXT,
        finish_lat REAL,
        finish_lng REAL,
        learned_today TEXT,
        feedback TEXT
      )
    ''');
  }

  Future<void> insertCheckin(CheckinRecord record) async {
    final db = await database;
    await db.insert(
      'checkins',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Sync new record to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('checkins')
          .doc(record.id)
          .set(record.toMap());
    } catch (e) {
      debugPrint('Error syncing to Firestore: \$e');
    }
  }

  Future<void> updateFinishClass({
    required String id,
    required DateTime finishTime,
    required double finishLat,
    required double finishLng,
    required String learnedToday,
    required String feedback,
  }) async {
    final db = await database;
    await db.update(
      'checkins',
      {
        'finish_time': finishTime.toIso8601String(),
        'finish_lat': finishLat,
        'finish_lng': finishLng,
        'learned_today': learnedToday,
        'feedback': feedback,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Sync finish update to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('checkins')
          .doc(id)
          .update({
        'finish_time': finishTime.toIso8601String(),
        'finish_lat': finishLat,
        'finish_lng': finishLng,
        'learned_today': learnedToday,
        'feedback': feedback,
      });
    } catch (e) {
      debugPrint('Error syncing update to Firestore: \$e');
    }
  }

  Future<List<CheckinRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('checkins', orderBy: 'checkin_time DESC');
    return maps.map((map) => CheckinRecord.fromMap(map)).toList();
  }

  Future<List<CheckinRecord>> getActiveRecords() async {
    final db = await database;
    final maps = await db.query(
      'checkins',
      where: 'finish_time IS NULL',
      orderBy: 'checkin_time DESC',
    );
    return maps.map((map) => CheckinRecord.fromMap(map)).toList();
  }
}
