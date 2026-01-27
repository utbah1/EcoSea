import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import '../mod/user_profile.dart';
import 'auth_expired_exception.dart';

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

  static Map<String, String> _authHeaders(String token) => {
        "Authorization": "Bearer $token",
      };

  static Future<UserProfile> getMe() async {
    final token = (await _getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const AuthExpiredException();
    }

    try {
      final res = await _dio.get(
        "/api/me",
        options: Options(headers: _authHeaders(token)),
      );

      if (res.statusCode == 200 && res.data != null) {
        return UserProfile.fromJson(Map<String, dynamic>.from(res.data));
      }

      if (res.statusCode == 404) {
        throw const AuthExpiredException();
      }

      throw Exception("Gagal mengambil data profil.");
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404 || status == 403) {
        throw const AuthExpiredException();
      }
      rethrow;
    }
  }

  static Future<UserProfile> updateName({required String name}) async {
    final token = (await _getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const AuthExpiredException();
    }

    final clean = name.trim();
    if (clean.isEmpty) {
      throw Exception("Nama tidak boleh kosong");
    }

    try {
      final res = await _dio.patch(
        "/api/me",
        data: {"name": clean},
        options: Options(headers: _authHeaders(token)),
      );

      if (res.statusCode == 200 && res.data is Map && res.data["user"] != null) {
        return UserProfile.fromJson(Map<String, dynamic>.from(res.data["user"]));
      }

      throw Exception("Gagal memperbarui nama.");
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404 || status == 403) {
        throw const AuthExpiredException();
      }
      final msg = e.response?.data?["message"];
      if (msg != null) throw Exception(msg.toString());
      rethrow;
    }
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = (await _getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const AuthExpiredException();
    }

    try {
      final res = await _dio.post(
        "/api/me/change-password",
        data: {
          "old_password": oldPassword,
          "new_password": newPassword,
        },
        options: Options(headers: _authHeaders(token)),
      );

      if (res.statusCode == 200) return;
      throw Exception("Gagal mengganti password.");
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404 || status == 403) {
        throw const AuthExpiredException();
      }
      final msg = e.response?.data?["message"];
      if (msg != null) throw Exception(msg.toString());
      rethrow;
    }
  }

  static Future<UserProfile> uploadProfilePhoto({required File file}) async {
    final token = (await _getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const AuthExpiredException();
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final form = FormData.fromMap({
      "photo": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final res = await _dio.post(
        "/api/me/photo",
        data: form,
        options: Options(
          headers: {
            ..._authHeaders(token),
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (res.statusCode == 200 && res.data is Map && res.data["user"] != null) {
        return UserProfile.fromJson(Map<String, dynamic>.from(res.data["user"]));
      }

      throw Exception("Gagal mengunggah foto profil.");
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404 || status == 403) {
        throw const AuthExpiredException();
      }
      final msg = e.response?.data?["message"];
      if (msg != null) throw Exception(msg.toString());
      rethrow;
    }
  }
}
