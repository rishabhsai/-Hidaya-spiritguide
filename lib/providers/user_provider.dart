import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> completeOnboarding(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await ApiService.createUser(userData);
      await loadUserStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await ApiService.getUser(userId);
      await loadUserStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserStats() async {
    if (_user == null) return;

    try {
      _stats = await ApiService.getUserStats(_user!.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _stats = null;
    _error = null;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
} 