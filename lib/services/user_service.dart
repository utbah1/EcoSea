import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import '../mod/user_profile.dart';

class UserService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
  );

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<UserProfile> getMe() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    final res = await _dio.get(
      "/api/me",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (res.statusCode == 200 && res.data != null) {
      return UserProfile.fromJson(Map<String, dynamic>.from(res.data));
    }

    throw Exception("Gagal mengambil data profil.");
  }
}
