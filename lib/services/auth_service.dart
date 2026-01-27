import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  /// Berisi alasan terakhir kenapa Google login gagal (untuk ditampilkan di UI / debug).
  String? lastGoogleError;

  /// Ringkasan konfigurasi runtime (berguna untuk debug di device).
  String get debugConfig =>
      "API_BASE_URL=${ApiConfig.baseUrl} | GOOGLE_WEB_CLIENT_ID=${ApiConfig.googleWebClientId.isEmpty ? 'KOSONG' : 'SET'}";

  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post(
        "/api/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res.data['access_token']);
      await prefs.setString("role", res.data['role']);

      return true;
    } catch (e) {
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
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      lastGoogleError = null;

    final googleSignIn = GoogleSignIn(
      scopes: const ["email"],
      serverClientId: ApiConfig.googleWebClientId.isEmpty ? null : ApiConfig.googleWebClientId,
    );

    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final account = await googleSignIn.signIn();

      if (account == null) {
        lastGoogleError = "Dibatalkan oleh pengguna";
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        lastGoogleError =
            "idToken kosong. Isi GOOGLE_WEB_CLIENT_ID (Web OAuth Client ID) dan pastikan konfigurasi SHA-1 + package name benar.";
        return false;
      }

      final res = await _dio.post(
        "/api/google-login",
        data: {"id_token": idToken},
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res.data['access_token']);
      await prefs.setString("role", res.data['role']);

      return true;
    } on DioException catch (e) {
      final detail = () {
        try {
          final d = e.response?.data;
          if (d is Map && d['message'] != null) return d['message'].toString();
          return e.message ?? e.toString();
        } catch (_) {
          return e.message ?? e.toString();
        }
      }();

      lastGoogleError =
          "Gagal menghubungi backend (${ApiConfig.baseUrl}). Jika pakai emulator Android, gunakan API_BASE_URL=http://10.0.2.2:5000 (bukan localhost). Detail: $detail";
      debugPrint(lastGoogleError);
      return false;
    } on PlatformException catch (e) {
      final msg = e.message ?? '';
      final api10Hint = (msg.contains('ApiException: 10') || msg.contains('DEVELOPER_ERROR'))
          ? " (Biasanya karena SHA-1 / package name tidak cocok di Firebase/Google Cloud, atau google-services.json belum benar.)"
          : "";

      lastGoogleError =
          "Google Sign-In error: ${e.code}${msg.isNotEmpty ? ' - $msg' : ''}$api10Hint";
      debugPrint(lastGoogleError);
      return false;
    } catch (e) {
      lastGoogleError = "Google Sign-In error: $e";
      debugPrint(lastGoogleError);
      return false;
    }
  }
}