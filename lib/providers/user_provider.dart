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
} 