import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _error;

  User? get user => _user;
  String? get error => _error;

  Future<void> createUser(String name, String selectedReligion) async {
    try {
      _user = await ApiService.createUser(name, selectedReligion);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      try {
        _user = await ApiService.getUser(_user!.id);
        _error = null;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> updateStreak() async {
    if (_user != null) {
      try {
        await ApiService.updateUserStreak(_user!.id);
        await refreshUser(); // Refresh to get updated streak
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  void setUser(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }
} 