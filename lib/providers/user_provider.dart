import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _error;

  User? get user => _user;
  String? get error => _error;

  Future<void> createUser(String persona) async {
    _user = await ApiService.createUser(persona);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      try {
        _user = await ApiService.getUser(_user!.id);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }
} 