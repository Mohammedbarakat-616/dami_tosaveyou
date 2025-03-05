import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dami_tosaveyou/database/database_helper.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toMap()));
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final userData = await dbHelper.getUserById(_user!.id);
      if (userData != null) {
        _user = User.fromMap(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> logout() async {
    if (_user != null) {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteUser(_user!.id);
    }
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;

  Future<void> updateUser(
      {required String name,
      required String email,
      required String phone}) async {
    if (_user != null) {
      _user = _user!.copyWith(name: name, email: email, phone: phone);
      try {
        await DatabaseHelper.instance.updateUser(_user!.id, name, email, phone);
        notifyListeners();
      } catch (e) {
        print('Error updating user: $e');
      }
    }
  }
}
