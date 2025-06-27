import 'package:flutter/material.dart';
import 'package:steam/models/user.dart';
import 'package:steam/repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    try {
      final isValid = await _userRepository.authenticate(username, password);
      if (isValid) {
        _currentUser = await _userRepository.getUserByUsername(username);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> register(User user) async {
    try {
      final existingUser = await _userRepository.getUserByUsername(user.username);
      if (existingUser != null) {
        return false;
      }
      
      await _userRepository.insertUser(user);
      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await _userRepository.updateUser(user);
      if (_currentUser?.id == user.id) {
        _currentUser = user;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }
}
