import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/blood_request.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class BloodRequestProvider with ChangeNotifier {
  List<BloodRequest> _requests = [];
  List<BloodRequest> _userRequests = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<BloodRequest> get requests => [..._requests];
  List<BloodRequest> get userRequests => [..._userRequests];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('requests');
      _requests = maps.map((map) => BloodRequest.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserRequests(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'requests',
        where: 'createdBy = ?',
        whereArgs: [userId],
      );
      _userRequests = maps.map((map) => BloodRequest.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching user requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRequest(BloodRequest request) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'requests',
        request.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await fetchRequests();
      await fetchUserRequests(
          request.createdBy); // تحديث قائمة الطلبات الخاصة بالمستخدم
      notifyListeners(); // تحديث المستمعين بعد إضافة الطلب
    } catch (e) {
      print('Error adding request: $e');
    }
  }

  Future<void> updateRequest(BloodRequest request) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'requests',
        request.toMap(),
        where: 'id = ?',
        whereArgs: [request.id],
      );
      await fetchRequests();
      notifyListeners(); // تحديث المستمعين بعد تحديث الطلب
    } catch (e) {
      print('Error updating request: $e');
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'requests',
        where: 'id = ?',
        whereArgs: [id],
      );
      await fetchRequests();
    } catch (e) {
      print('Error deleting request: $e');
    }
  }

  List<BloodRequest> searchRequests({
    String? bloodType,
    String? location,
    String? status,
  }) {
    return _requests.where((request) {
      bool matchesBloodType =
          bloodType == null || request.bloodType == bloodType;
      bool matchesLocation = location == null ||
          request.location.toLowerCase().contains(location.toLowerCase());
      bool matchesStatus = status == null || request.status == status;
      return matchesBloodType && matchesLocation && matchesStatus;
    }).toList();
  }

  List<BloodRequest> getUrgentRequests() {
    return _requests
        .where((request) => request.urgency == 'حرج')
        .toList(); // الحصول على الطلبات العاجلة
  }

  Future<List<Map<String, String>>> searchDonors({
    String? bloodType,
    String? location,
  }) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'donors',
        where: 'bloodType = ? AND location LIKE ?',
        whereArgs: [bloodType, '%$location%'],
      );
      return maps
          .map((map) => {
                'name': map['name'] as String,
                'bloodType': map['bloodType'] as String,
                'phone': map['phone'] as String,
              })
          .toList();
    } catch (e) {
      print('Error searching donors: $e');
      return [];
    }
  }

  Future<void> fetchRequestById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final request = await _dbHelper.getRequestById(id);
      if (request != null) {
        _requests = [request];
      }
    } catch (e) {
      print('Error fetching request by ID: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> fetchUserByPhone(String phone) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
    } catch (e) {
      print('Error fetching user by phone: $e');
    }
    return null;
  }
}
