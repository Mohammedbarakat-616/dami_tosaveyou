import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blood_request.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('blood_donation.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const doubleType = 'REAL';

    await db.execute('''
    CREATE TABLE users (
      id $idType,
      name $textType,
      email $textType UNIQUE,
      role $textType,
      bloodType $textType,
      lastDonationDate $textType,
      locationLat $doubleType NOT NULL,
      locationLong $doubleType NOT NULL,
      phone $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE requests (
      id $idType,
      bloodType $textType,
      status $textType,
      createdBy $textType,
      createdAt $textType,
      location $textType,
      urgency $textType,
      description $textType
    )
    ''');
  }

  Future<void> saveUser(
      String id,
      String name,
      String email,
      String role,
      String bloodType,
      double locationLat,
      double locationLong,
      String phone) async {
    final db = await instance.database;
    try {
      await db.insert(
        'users',
        {
          'id': id,
          'name': name,
          'email': email,
          'role': role,
          'bloodType': bloodType,
          'lastDonationDate': DateTime.now().toIso8601String(),
          'locationLat': locationLat,
          'locationLong': locationLong,
          'phone': phone,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(
      String id, String name, String email, String phone) async {
    final db = await instance.database;
    try {
      await db.update(
        'users',
        {
          'name': name,
          'email': email,
          'phone': phone,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<void> deleteUser(String id) async {
    final db = await instance.database;
    try {
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> saveBloodRequest(BloodRequest request) async {
    final db = await instance.database;
    try {
      await db.insert(
        'requests',
        request.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving blood request: $e');
    }
  }

  Future<List<BloodRequest>> getBloodRequests() async {
    final db = await instance.database;
    try {
      final result = await db.query('requests');
      return result.map((json) => BloodRequest.fromMap(json)).toList();
    } catch (e) {
      print('Error getting blood requests: $e');
      return [];
    }
  }

  Future<BloodRequest?> getRequestById(String id) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        'requests',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return BloodRequest.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error getting request by ID: $e');
      return null;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
