import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post(
        "/api/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      print("LOGIN RESPONSE: ${res.data}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res.data['access_token']);
      await prefs.setString("role", res.data['role']);

      return true;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  // REGISTER
  Future<bool> register(String nama, String email, String password) async {
    try {
      await _dio.post(
        "/api/register",
        data: {
          "nama": nama,
          "email": email,
          "password": password,
        },
      );
      return true;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }
}