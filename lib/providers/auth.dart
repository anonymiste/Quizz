import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:quizz_interface/services/auth.api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiAuthService = AuthApiService();
  String? _authToken;
  UserModel? _currentUser;

  String? get token => _authToken;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _authToken != null;

  set token(String? token) {
    _authToken = token;
    notifyListeners();
  }

  String? getAuthToken() => _authToken;

  Future<Response> login(String email) async {
    final response = await _apiAuthService.login(email);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _authToken = response.data['token'];
      if (response.data['user'] != null) {
        _currentUser = UserModel.fromJson(response.data['user']);
      }
      notifyListeners();
    }
    return response;
  }

  Future<Response> logout(UserModel user) async {
    _authToken = null;
    _currentUser = null;
    notifyListeners();
    return await _apiAuthService.logout(user);
  }

  Future<Response> me() async {
    return await _apiAuthService.me();
  }

  Future<Response> profileUpdate(UserModel updatedUser) async {
    return await _apiAuthService.profileUpdate(updatedUser);
  }

  Future<Response> profileDelete(UserModel user) async {
    return await _apiAuthService.profileDelete(user);
  }
}