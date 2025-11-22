// lib/services/auth_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserModel {
  final int? id;
  final String? email;
  final Map<String, dynamic>? raw;

  UserModel({this.id, this.email, this.raw});

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m.containsKey('id') ? (m['id'] is int ? m['id'] as int : int.tryParse(m['id'].toString())) : null,
      email: m['email']?.toString(),
      raw: m,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email)';
}

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  String? token;
  String? errorMessage;
  bool _loading = false;

  bool get loading => _loading;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  /// Attempts login and persists token/profile_pic
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final Map<String, dynamic> res = await ApiService.loginUser(email, password);
      if (kDebugMode) {
        // ignore: avoid_print
        print('DEBUG AuthProvider.login -> response: $res');
      }

      final bool success = (res['success'] == true) || (res['status'] == 'ok') || (res['token'] != null) || (res['access_token'] != null);
      if (!success) {
        errorMessage = (res['message'] ?? res['error'] ?? res['msg'] ?? 'Invalid credentials').toString();
        _setLoading(false);
        return false;
      }

      token = (res['token'] ?? res['access_token'] ?? res['data']?['token'])?.toString();

      // persist token
      try {
        final sp = await SharedPreferences.getInstance();
        if (token != null && token!.isNotEmpty) await sp.setString('auth_token', token!);
      } catch (_) {}

      // extract user
      Map<String, dynamic>? userMap;
      if (res['user'] is Map<String, dynamic>) {
        userMap = res['user'] as Map<String, dynamic>;
      } else if (res['data'] is Map<String, dynamic> && res['data']['user'] is Map<String, dynamic>) {
        userMap = res['data']['user'] as Map<String, dynamic>;
      } else if (res['results'] is Map<String, dynamic>) {
        userMap = res['results'] as Map<String, dynamic>;
      } else if (res['data'] is Map<String, dynamic>) {
        userMap = res['data'] as Map<String, dynamic>;
      }

      if (userMap != null && userMap.isNotEmpty) {
        user = UserModel.fromMap(userMap);
        // persist profile_pic minimally
        try {
          final sp = await SharedPreferences.getInstance();
          final pic = userMap['profile_pic']?.toString();
          if (pic != null && pic.isNotEmpty) await sp.setString('profile_pic', pic);
        } catch (_) {}
      } else {
        user = UserModel(id: null, email: email, raw: res);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e, st) {
      _setLoading(false);
      errorMessage = 'Network error: $e';
      if (kDebugMode) {
        // ignore: avoid_print
        print('DEBUG AuthProvider.login exception: $e\n$st');
      }
      notifyListeners();
      return false;
    }
  }

  /// Fetch latest /api/me and update user/token if needed.
  Future<bool> fetchMe() async {
    if (token == null) {
      final sp = await SharedPreferences.getInstance();
      token = sp.getString('auth_token');
      if (token == null) return false;
    }
    try {
      final Map<String, dynamic> res = await ApiService.fetchMe(token: token);
      if (res['success'] == true || res['statusCode'] == 200 || res['id'] != null) {
        Map<String, dynamic>? userMap = res;
        if (res['user'] is Map<String, dynamic>) userMap = res['user'] as Map<String, dynamic>;
        user = UserModel.fromMap(userMap);
        try {
          final sp = await SharedPreferences.getInstance();
          final pic = user?.raw?['profile_pic']?.toString();
          if (pic != null && pic.isNotEmpty) await sp.setString('profile_pic', pic);
        } catch (_) {}
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DEBUG fetchMe error $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    token = null;
    user = null;
    errorMessage = null;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('auth_token');
      await sp.remove('profile_pic');
    } catch (_) {}
    notifyListeners();
  }
}
